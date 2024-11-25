using LinearAlgebra
using Plots, ProgressMeter, Logging
using NPZ

scale(x, γ=1e-2) = sign(x) * (log10(abs(x) + γ) - log10(γ))

subsamp = 50
lag = 10 
dim = 30
data = npzread("./alanine-dipeptide-3x250ns-heavy-atom-positions.npz")
angledata = npzread("./alanine-dipeptide-3x250ns-backbone-dihedrals.npz")
X = permutedims(data["arr_0"][1:subsamp:end-lag+1, 1:dim])
Y = permutedims(data["arr_0"][lag:subsamp:end, 1:dim])
α = angledata["arr_0"][1:subsamp:end, :]

k(x, y, c=0.01) = exp(-norm(x-y)^2 / c)

Ĝ = @showprogress [k(xj, xk, 0.01) for xj in eachcol(X), xk in eachcol(X)]
Â = @showprogress [k(yj, xk, 0.01) for yj in eachcol(Y), xk in eachcol(X)]
Ĵ = @showprogress [k(yj, yk, 0.01) for yj in eachcol(Y), yk in eachcol(Y)]

σ, Q = eigen(Ĝ)
r = 50#sum(σ .> 1e-4)

Σ̂ = Diagonal( sqrt.(σ[end-r+1:end]) )
Q̂ = Q[:, end-r+1:end]

Σ̂⁺ = inv(Σ̂)
K̂ = (Σ̂⁺*Q̂') * Â * (Q̂*Σ̂⁺)
M̂ = (Q̂*Σ̂⁺)' * Ĵ * (Q̂*Σ̂⁺)

function res(z, G=I(r), A=K̂, J=M̂)
    U = J - z' * A - z * A' + z'z * G
    ξ = real.( eigvals(U, G) )
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.02:1.2
z_grid = xs' .+ ys .* im

residuals = @showprogress map(res, z_grid)

λ, ev = eigen(K̂)

p1 = plot(exp.(im .* (-π:0.001:π)), 
    style=:dash, aspectratio=1., leg=false, color=:blue
)
scatter!(λ, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=:purple
)
contour!(xs, ys, residuals, 
    colormap=:acton, linewidth=2,
    xlims=(-1.2,1.2), ylims=(-1.2,1.2),
    clabels=true, cbar=false,
    levels=[0.05:0.1:0.35; 0.5:0.25:1]
)

perm = sortperm(
    λ, by=x->abs(1-x)
)

λ = λ[perm]
ev = ev[:, perm]
ψ = real.(Q̂*Σ̂ * ev)

v = ψ[:, 2]
mid = ( maximum(v) + minimum(v) ) / 2
p2 = scatter(
    α[:, 1], α[:, 2], 
    zcolor=sign.(v) .- mid, 
    m=(:berlin, 0.8), lab="",
    clims=(-1,1),
    cbar=false
)


p = plot(p1, p2, size=(700,300))
savefig(p, "../figures/molecule.pdf")
