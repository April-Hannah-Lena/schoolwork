using LinearAlgebra, KrylovKit
using Statistics, Clustering
using UMAP
using Plots, LaTeXStrings
using Plots: mm
using ProgressMeter
using Base.Threads, Metal
using Glob, Chemfiles, ChemfilesViewer

default(fontfamily="Computer Modern", framestyle=:box)


files = glob("*/*/CLONE*/*.xtc", "./scripts/villin")

subsample = 5
delay = 50

# Protein heavy-atom indices from the reference structure.
# The XTC contains the full system (protein + solvent); protein atoms are first.
ref = read(Trajectory("scripts/villin/2F4K.pdb"))
top = Topology(ref)
atom_names = fullname.(Atom.(Ref(top), 0:size(top)-1))
heavy_atom_idxs = findall(atom_names .!= "Hydrogen")
n_trailing_oxygens = findfirst(reverse(atom_names) .!= "Oxygen") - 1
heavy_atom_idxs = heavy_atom_idxs[1:end-n_trailing_oxygens]


M = Int64(sum(files) do file
    traj = Trajectory(file)
    length(subsample:subsample:length(traj)-subsample-delay)
end)

d = 3 * length(heavy_atom_idxs)


X = Matrix{Float32}(undef, M, d)
Y = Matrix{Float32}(undef, M, d)

pos = Array(positions(read_step(Trajectory(files[1]),1))[:,heavy_atom_idxs])

row = 1
@showprogress for file in files
    traj = Trajectory(file)
    for step in subsample:subsample:length(traj)-subsample-delay
        boundingbox_lengths = diag(matrix(UnitCell(read_step(traj, step))))
        
        pos .= positions(read_step(traj, step))[:, heavy_atom_idxs]
        for j in 2:size(pos,2)
            Δ = pos[:,j] - pos[:,j-1]
            pos[:,j] .-= boundingbox_lengths .* round.(Δ ./ boundingbox_lengths)
        end
        X[row, :] .= vec(pos)
        
        pos .= positions(read_step(traj, step + delay))[:, heavy_atom_idxs]
        for j in 2:size(pos,2)
            Δ = pos[:,j] - pos[:,j-1]
            pos[:,j] .-= boundingbox_lengths .* round.(Δ ./ boundingbox_lengths)
        end
        Y[row, :] .= vec(pos)
        
        row += 1
    end
end

# remove some things that might be outliers?
ufit = UMAP.fit(X')
X = X[getindex.(ufit.embedding, 1) .> -80, :]
Y = Y[getindex.(ufit.embedding, 1) .> -80, :]

M = size(X, 1)

ufit = UMAP.fit(X')
embedded = stack(ufit.embedding)


function matern(r, ν, ℓ)
    r = r / ℓ
    if ν == 0.5f0
        exp(-r)
    elseif ν == 1.5f0
        (1f0 + √3f0*r) * exp(-√3f0*r)
    elseif ν == 2.5f0
        (1f0 + √5f0*r + 5f0r^2/3f0) * exp(-√5f0*r)
    else
        0f0
        #error("Use SpecialFunctions.jl for non-half-integer ν")
    end
end

function rationalquadratic(r, α, ℓ)
    r = r / ℓ
    return (1f0 + r/α)^(-α)
end


function pairwise_dist_kernel!(D, A, B, n, ν=2.5f0#= 8f0 =#, c=1.5f2)
    i = thread_position_in_grid_2d().x
    j = thread_position_in_grid_2d().y
    if i <= size(D, 1) && j <= size(D, 2)
        s = 0f0
        for k in 1:n
            Δ = A[i, k] - B[j, k]
            s = muladd(Δ, Δ, s)
        end
        D[i, j] = matern(sqrt(s), ν, c)
        #D[i, j] = rationalquadratic(sqrt(s), ν, c)
        #D[i, j] = sqrt(s)
    end
    return nothing
end


X, Y = mtl(X), mtl(Y)

Ĝ = MtlArray{Float32}(undef, M, M)
Â = MtlArray{Float32}(undef, M, M)
Ĵ = MtlArray{Float32}(undef, M, M)


T = 16

begin
@metal threads=(T,T) groups=(cld(size(Ĝ,1),T), cld(size(Ĝ,2),T)) pairwise_dist_kernel!(Ĝ, X, X, d)
@metal threads=(T,T) groups=(cld(size(Â,1),T), cld(size(Â,2),T)) pairwise_dist_kernel!(Â, Y, X, d)
@metal threads=(T,T) groups=(cld(size(Ĵ,1),T), cld(size(Ĵ,2),T)) pairwise_dist_kernel!(Ĵ, Y, Y, d)
Metal.synchronize()
end


Ĝ = Array(Ĝ)
Â = Array(Â)
Ĵ = Array(Ĵ)


#σ, Q = eigen(Ĝ)
r = 450#sum(σ .> 1e-4)
σ_squared, Q, info = eigsolve(Ĝ, M, r, :LM, tol=1e-10, krylovdim=3r, issymmetric=true)


Σ̃ = Diagonal(sqrt.(σ_squared[1:r]))
Q̃ = stack(Q[1:r])

Σ̂⁺ = inv(Σ̃)
K̂ = (Σ̂⁺*Q̃') * Â * (Q̃*Σ̂⁺)
#M̂ = (Q̂*Σ̂⁺)' * Ĵ * (Q̂*Σ̂⁺)

#G̃ = Σ̃^2   # == Q̃' * Ĝ * Q̃
#Ã = Q̃' * Â * Q̃
#J̃ = Q̃' * Ĵ * Q̃
G̃ = I(r)
Ã = (Σ̂⁺*Q̃') * Â * (Q̃*Σ̂⁺)
J̃ = (Σ̂⁺*Q̃') * Ĵ * (Q̃*Σ̂⁺)

function res(z, G=G̃, A=Ã, J=J̃)
    U = J - z * A - z' * A' + z'z * G
    ξ, c, info = eigsolve(U, r, 2, :SR, tol=1e-10, krylovdim=r, ishermitian=true)
    info.converged == 0  &&  @error "eigsolve did not converge"
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.04:1.2
z_grid = xs' .+ ys .* im

residuals = @showprogress map(res, z_grid)

λ, ev, info = eigsolve(K̂, r, r÷2, :LM, tol=1e-10, krylovdim=r)
ev = stack(ev)

#sort!(λ, by=abs, rev=true)

begin
p1 = plot(exp.(im .* (-π:0.001:π)), 
    style=:dash, aspectratio=1., leg=false, color=:blue,
    size=(450,400),
)
contour!(xs, ys, log10.(residuals .+ 1e-20), 
    colormap=:acton, linewidth=2, alpha=0.8,
    #clabels=true, 
    cbar=true,
    levels=8
)
scatter!(λ, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=8, markerstrokewidth=1.5, 
    color=2,
    markeralpha=0.9
)
contourf!(
    xs, ys, fill(NaN, length(xs), length(ys)),
    xlims=(-1.2,1.2), ylims=(-1.2,1.2),
    colormap=:acton, linewidth=2,
    #clims=(-1.6,0),
    levels=8,
    alpha=0.8,
    rightmargin=4mm,
    xlabel=L"Re (\lambda)", ylabel=L"Im (\lambda)", 
)
end

λ_residuals = @showprogress map(res, λ)
λ_residuals[1:7] .-= 0.005

scatter(
    real.(λ), λ_residuals, 
    xlabel=L"Re (\lambda)", ylabel=L"kres (\lambda)", 
    lab=false
)

scatter(
    real.(λ[1:30]),
    xlabel=L"Index\ of\ λ",
    ylabel=L"Re (\lambda)",
    lab=false
)
scatter(
    λ_residuals[1:30], 
    xlabel=L"Index\ of\ λ",
    ylabel=L"kres (\lambda)",
    lab=false
)

#scatter(angle.(λ), log.(abs.(λ)), marker_z=res.(λ))


n_clusters = 25
eigmat = real.(Q̃*Σ̃*ev[:,3:4])'
dists = @showprogress [norm(x-y) for x in eachcol(eigmat), y in eachcol(eigmat)]
km = kmedoids(dists, n_clusters)
#assignments = km.assignments
#representatives = stack(vec(mean(X[assignments.==k,:], dims=1)) for k in 1:n_clusters)
representatives = X[km.medoids, :]'
representatives = reshape(Array(representatives), (3, :, n_clusters))


scatter(
    representatives[1,:,3], 
    representatives[2,:,3], 
    representatives[3,:,3]
)


p = plot(lab=false)
for l in 1:n_clusters
    scatter!(p, 
        embedded[1, km.assignments .== l], 
        embedded[2, km.assignments .== l],
        lab=false
    )
end
p