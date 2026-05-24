using LinearAlgebra, KrylovKit
using Statistics, Clustering
using Plots, LaTeXStrings
using Plots: mm
using ProgressMeter
using DelimitedFiles
using Base.Threads, Metal

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


Ĝ = mtl(readdlm("scripts/ocean/distances/distances_XX.csv", ',', Float32))
Â = mtl(readdlm("scripts/ocean/distances/distances_XY.csv", ',', Float32))
Ĵ = mtl(readdlm("scripts/ocean/distances/distances_YY.csv", ',', Float32))

map!(r -> matern(r, 2.5f0, 20), Ĝ, Ĝ)
map!(r -> matern(r, 2.5f0, 20), Â, Â)
map!(r -> matern(r, 2.5f0, 20), Ĵ, Ĵ)


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
