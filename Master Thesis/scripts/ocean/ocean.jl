using LinearAlgebra, KrylovKit
using Statistics, Clustering
using Plots, LaTeXStrings
using Plots: mm
using ProgressMeter
using DelimitedFiles
using Base.Threads, Metal

include("seba.jl")

default(fontfamily="Computer Modern", framestyle=:box)


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


Ĝ = mtl(readdlm("distances/distances_XX.csv", ',', Float32))
Â = mtl(readdlm("distances/distances_XY.csv", ',', Float32))
Ĵ = mtl(readdlm("distances/distances_YY.csv", ',', Float32))

map!(r -> matern(r, 2.5f0, 70), Ĝ, Ĝ)
map!(r -> matern(r, 2.5f0, 70), Â, Â)
map!(r -> matern(r, 2.5f0, 70), Ĵ, Ĵ)


Ĝ = Array(Ĝ)
Â = Array(Â)
Ĵ = Array(Ĵ)

M = size(Ĝ, 1)
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

function res(z, G=G̃, A=Ã, J=J̃; vector=false)
    U = J - z * A - z' * A' + z'z * G
    ξ, c, info = eigsolve(U, r, 2, :SR, tol=1e-10, krylovdim=r, ishermitian=true)
    info.converged == 0  &&  @error "eigsolve did not converge"
    vector  &&  return c[1]
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.05:1.2
z_grid = xs' .+ ys .* im

residuals = @showprogress map(res, z_grid)

λ, ev, info = eigsolve(K̂, r, 6#= r÷2 =#, :LM, tol=1e-10, krylovdim=r)
ev = stack(ev)

function is_local_minimum(ind, residuals=residuals, xs=xs, ys=ys)
    i,j = Tuple(ind)
    ( min(i,j) == 1  ||  i == length(xs)  ||  j == length(ys) )  &&  return false
    all(residuals[i,j] ≤ residuals[k,l] for k in i-1:i+1, l in j-1:j+1)
end

local_minima = z_grid[is_local_minimum.(CartesianIndices(z_grid))]
res_ev = stack(res.(local_minima, vector=true))

#sort!(λ, by=abs, rev=true)

begin
p1 = plot(exp.(im .* (-π:0.001:π)), 
    style=:dash, aspectratio=1., leg=false, color=:blue,
    size=(450,400),
)
contour!(xs, ys, residuals,#log10.(residuals .+ 1e-20), 
    colormap=:acton, linewidth=2, alpha=0.8,
    #clabels=true, 
    cbar=true,
    levels=15
)
scatter!(λ, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=8, markerstrokewidth=1.5, 
    color=2,
    markeralpha=0.9
)
scatter!(local_minima,
    marker=:x,
    markersize=6, markerstrokewidth=2, 
    color=9, 
    markeralpha=0.9
)
contourf!(
    xs, ys, fill(NaN, length(xs), length(ys)),
    xlims=(-1.2,1.2), ylims=(-1.2,1.2),
    #xlims=(0.8,1.2), ylims=(-0.2,0.2),
    colormap=:acton, linewidth=2,
    clims=(0,0.5),#(-1.6,0),
    levels=15,
    alpha=0.8,
    rightmargin=4mm,
    xlabel=L"Re (\lambda)", ylabel=L"Im (\lambda)", 
)
#plot!(0.16 .+ 0.8 .* exp.(im .* (-π:0.001:π)))

end


savefig(p1, "ocean_spectrum.pdf")

clip(x, lo, hi) = max(min(x, hi), lo)

mask = (abs.(λ .- 0.16) .> 0.8)  .&  (imag.(λ) .> 0)

# sum conjugate pairs
vecs = [
    real.(res_ev[:,1]);;
    real.(res_ev[:,2]);;
    imag.(res_ev[:,2]);;
]
vecs = Q̃ * Σ̃ * vecs
vecs = [vecs; zeros((14, size(vecs,2)))]
writedlm("candidates.csv", real.(vecs'), ',')

X1 = readdlm("X1.csv", ',', Float32)
#X1 = X1[1:3:end]

# python to convert kernel candidates back to spatially evaluated candidates
candidates_spatial = readdlm("candidates_spatial.csv", ',', Float32)
useful = (X1 .!= 0)[eachindex(X1) .% 3 .> 0]

S, R = seba(candidates_spatial[:, useful]')#[:, 2:2:end]
candidates_spatial[:,useful] .= S'
candidates_spatial[:,.!useful] .= 0

S̄, Ā, τ = partition_unity(S)
candidates_spatial[:,useful] .= S̄'

n_clusters = 10
km = kmeans(candidates_spatial, n_clusters)
assignments = km.assignments
representatives = stack(vec(mean(X[assignments.==k,:], dims=1)) for k in 1:n_clusters)




latitude = vec(readdlm("latitude.csv", ',', Float32))
longitude = vec(readdlm("longitude.csv", ',', Float32))

d = size(S,1)

pcbar = contourf(
    [1], [1], [1],
    cmap=:redsblues, clims=(-0.8, 0.8), 
    label=false, framestyle=:none, 
    rightmargin=4Plots.mm, 
    colorbar_tickfontsize=10, 
    size=(100,300), 
    levels=50
)

savefig(pcbar, "pcbar.pdf")

figs_x = [
    begin
        #plotmatrix = reshape(sum(candidates_spatial[2, k:3:end]' for k in 1:3), (length(longitude), length(latitude)))
        plotmatrix = clip.(reshape(candidates_spatial[k, 1:2:end]', (length(longitude), length(latitude))), -0.8, 0.8)
        #plotmatrix = clip.(reshape(S[1:2:end,k], (length(longitude), length(latitude))), -0.5, 0.5)
        p = heatmap(longitude, latitude, plotmatrix', cmap=:redsblues, levels=50, clims=(-0.8,0.8))
        p = heatmap!(p,
            longitude,
            latitude,
            reshape(ifelse.(X1[1:3:end] .== 0, 1.0, NaN), (length(longitude), length(latitude)))',
            cmap=cgrad([:black, :black]),
            colorbar_entry=false,
            alpha=0.3, 
            cbar=false,
            xticks=false, 
            yticks=false
        )
    end
    for k in axes(S,2)
]

figs_y = [
    begin
        #plotmatrix = reshape(sum(candidates_spatial[2, k:3:end]' for k in 1:3), (length(longitude), length(latitude)))
        plotmatrix = clip.(reshape(candidates_spatial[k, 2:2:end]', (length(longitude), length(latitude))), -0.8, 0.8)
        #plotmatrix = clip.(reshape(S[2:2:end,k], (length(longitude), length(latitude))), -0.5, 0.5)
        p = heatmap(longitude, latitude, plotmatrix', cmap=:redsblues, levels=50, clims=(-0.8,0.8))
        p = heatmap!(p,
            longitude,
            latitude,
            reshape(ifelse.(X1[1:3:end] .== 0, 1.0, NaN), (length(longitude), length(latitude)))',
            cmap=cgrad([:black, :black]),
            colorbar_entry=false,
            alpha=0.3, 
            cbar=false,
            xticks=false, 
            yticks=false
        )
    end
    for k in axes(S,2)
]

interesting = [1,2,3]

layout = @layout [grid(3,2) a{0.19w}]
p = plot(
    permutedims([figs_x[interesting];; figs_y[interesting]])..., #pcbar, 
    layout=(3,2),
    #layout=layout, 
    size=(200*4, 200*3), 
    colorbar_tickfontsize=10, 
    topmargin=2Plots.mm
)

savefig(p, "ocean_seba.pdf")
