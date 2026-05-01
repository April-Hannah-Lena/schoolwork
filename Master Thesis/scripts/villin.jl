using LinearAlgebra, KrylovKit
using Statistics, Clustering
using Plots, LaTeXStrings
using Plots: mm
using ProgressMeter
using Base.Threads, Metal
using Glob, Chemfiles, ChemfilesViewer


files = glob("*/*/CLONE*/*.xtc", "./scripts/villin")

subsample = 20
delay = 4

M = Int64(sum(files) do file
    traj = Trajectory(file)
    length(subsample:subsample:length(traj)-subsample-delay)
end)

d = length(vec(positions(read_step(Trajectory(files[1]), subsample))))


X = Matrix{Float32}(undef, M, d)
Y = Matrix{Float32}(undef, M, d)

row = 1
for file in files
    traj = Trajectory(file)
    for step in subsample:subsample:length(traj)-subsample-delay
        X[row, :] .= vec(positions(read_step(traj, step)))
        Y[row, :] .= vec(positions(read_step(traj, step+delay)))
        row += 1
    end
end


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


function pairwise_dist_kernel!(D, A, B, n, ν=8f0#= 2.5f0 =#, c=1f3)
    i = thread_position_in_grid_2d().x
    j = thread_position_in_grid_2d().y
    if i <= size(D, 1) && j <= size(D, 2)
        s = 0f0
        for k in 1:n
            Δ = A[i, k] - B[j, k]
            s = muladd(Δ, Δ, s)
        end
        #D[i, j] = matern(sqrt(s), ν, c)
        D[i, j] = rationalquadratic(sqrt(s), ν, c)
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
r = 250#sum(σ .> 1e-4)
σ_squared, Q, info = eigsolve(Ĝ, M, r, :LM, tol=1e-7, krylovdim=3r, issymmetric=true)


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

#scatter(angle.(λ), log.(abs.(λ)), marker_z=res.(λ))


n_clusters = 5
km = kmeans(real.(Q̃*Σ̃*ev[:,2:4])', n_clusters)
assignments = km.assignments
representatives = stack(vec(mean(X[assignments.==k,:], dims=1)) for k in 1:n_clusters)
representatives = Array(reshape(representatives, 3, :, n_clusters))



frame = read(Trajectory("scripts/villin/2F4K.pdb"))
frame_pos = positions(frame)
frame_pos .= representatives[:,:,1]

render_molecule(frame)
