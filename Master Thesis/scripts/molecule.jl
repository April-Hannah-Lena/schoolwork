using LinearAlgebra, Clustering
using Plots, Colors, ProgressMeter, Logging, LaTeXStrings, Measures
using NPZ

default(fontfamily="Computer Modern", framestyle=:box)

scale(x, γ=1e-2) = sign(x) * (log10(abs(x) + γ) - log10(γ))

subsamp = 40
lag = 10 
dim = 30
data = npzread("./alanine-dipeptide-3x250ns-heavy-atom-positions.npz")
angledata = npzread("./alanine-dipeptide-3x250ns-backbone-dihedrals.npz")
X = permutedims(data["arr_0"][1:subsamp:end-lag+1, 1:dim])
Y = permutedims(data["arr_0"][lag:subsamp:end, 1:dim])
α = angledata["arr_0"][1:subsamp:end, :]
α1 = @view α[:, 1]
α2 = @view α[:, 2]

k(x, y, c=0.01) = exp(-norm(x-y)^2 / c)

Ĝ = @showprogress [k(xj, xk, 0.01) for xj in eachcol(X), xk in eachcol(X)]
Â = @showprogress [k(yj, xk, 0.01) for yj in eachcol(Y), xk in eachcol(X)]
Ĵ = @showprogress [k(yj, yk, 0.01) for yj in eachcol(Y), yk in eachcol(Y)]

σ, Q = eigen(Ĝ)
r = 150#sum(σ .> 1e-4)

Σ̃ = Diagonal( sqrt.(σ[end-r+1:end]) )
Q̃ = Q[:, end-r+1:end]

Σ̂⁺ = inv(Σ̃)
K̂ = (Σ̂⁺*Q̃') * Â * (Q̃*Σ̂⁺)
#M̂ = (Q̂*Σ̂⁺)' * Ĵ * (Q̂*Σ̂⁺)

G̃ = Σ̃^2   # == Q̃' * Ĝ * Q̃
Ã = Q̃' * Â * Q̃
J̃ = Q̃' * Ĵ * Q̃

function res(z, G=G̃, A=Ã, J=J̃)
    U = J - z' * A - z * A' + z'z * G
    ξ = real.( eigvals(U, G) )
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.02:1.2
z_grid = xs' .+ ys .* im

residuals = @showprogress map(res, z_grid)

λ, ev = eigen(K̂)

#sort!(λ, by=abs, rev=true)

p1 = plot(exp.(im .* (-π:0.001:π)), 
    style=:dash, aspectratio=1., leg=false, color=:blue,
    size=(450,400),
)
contour!(xs, ys, log10.(residuals .+ 1e-20), 
    colormap=:acton, linewidth=2, alpha=0.8,
    clabels=true, cbar=true,
    #levels=[0.05:0.1:0.35; 0.5:0.25:1]
    levels=[-1.5, -1.25, -1.0, -0.75, -0.5, -0.25, -0.1]
)
scatter!(λ[1:3], 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=8, markerstrokewidth=2.2, 
    color=2,
    markeralpha=0.9
)
scatter!(λ[4:end], 
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
    clims=(-1.6,0),
    alpha=0.8,
    rightmargin=4mm,
    xlabel=L"Re (\lambda)", ylabel=L"Im (\lambda)", 
)

savefig(p1, "../figures/molecule_spectrum.pdf")

perm = sortperm(
    λ, by=x->abs(1-x)
)

λ = λ[perm]
ev = ev[:, perm]
ψ = real.(Q̃*Σ̃ * ev)

v = -ψ[:, 2:3]
mid = ( maximum(v) + minimum(v) ) / 2
clims = (-1, 1)
p2 = scatter(
    α[:, 1], α[:, 2], 
    zcolor=sign.(v[:,1]) .- mid, 
    m=(:berlin, 0.8), lab="",
    clims=clims,
    cbar=false,
    xlabel=L"\varphi", ylabel=L"\psi",
)
p3 = scatter(
    α[:, 1], α[:, 2], 
    zcolor=sign.(v[:,2]) .- mid, 
    m=(:berlin, 0.8), lab="",
    clims=clims,
    cbar=true,
    xlabel=L"\varphi", ylabel=L"\psi",
)

p = plot(p2, p3, layout=grid(1,2, widths=(0.45,0.55)), size=(650,300))
savefig(p, "../figures/molecule.pdf")



clusters = kmeans(v', 4)
assignments = clusters.assignments
p4 = scatter(
    α1[assignments .== 2], α2[assignments .== 2], 
    lab="", alpha=0.8,
    xlabel=L"\varphi", ylabel=L"\psi",
    xlims=(-3.2,1.8), ylims=(-3.3,3.3),
    color=4,
    aspectratio=0.75,
    size=(400,400)
)
p4 = scatter!(
    α1[assignments .== 3], α2[assignments .== 3], 
    lab="", alpha=0.8,
    #xlabel=L"\varphi", ylabel=L"\psi",
    #xlims=(-3.2,1.8), ylims=(-3.3,3.3),
    color=3
)
p4 = scatter!(
    α1[assignments .== 4], α2[assignments .== 4], 
    lab="", alpha=0.8,
    #xlabel=L"\varphi", ylabel=L"\psi",
    #xlims=(-3.2,1.8), ylims=(-3.3,3.3),
    color=2
)
p4 = scatter!(
    α1[assignments .== 1], α2[assignments .== 1], 
    lab="", alpha=0.8,
    #xlabel=L"\varphi", ylabel=L"\psi",
    #xlims=(-3.2,1.8), ylims=(-3.3,3.3),
    color=1
)

savefig(p4, "../figures/kmeans.pdf")
