using LinearAlgebra, Statistics, StaticArrays
using LegendrePolynomials, FastGaussQuadrature
using DifferentialEquations, OrdinaryDiffEq
using Plots, ProgressMeter, Logging
import CairoMakie: Makie.streamplot, :(..), Point2, Point2f, save

scale(x, γ=1e-2) = sign(x) * (log10(abs(x) + γ) - log10(γ))
_x = -2:0.0001:2
_y = scale.(_x)
p1 = plot(_x, _y, leg=false, linewidth=3)
plot!(_x, identity, style=:dash)
savefig(p1, "../figures/symlog.pdf")

M = 500
_nodes, _weights = gausslegendre(M)

nodes = [2*SA_F64[x, y] for x in _nodes, y in _nodes]
weights = [w1*w2 for w1 in _weights, w2 in _weights]

N = 10
function basis(u, n1, n2)
    x, y = u
    if abs(x) > 2
        x = 2*sign(x)
    end
    if abs(y) > 2
        y = 2*sign(y)
    end
    x = x/2
    y = y/2
    x = Pl(x, n1, norm=Val(:normalized))
    y = Pl(y, n2, norm=Val(:normalized))
    x*y
end

dictionary = [u -> basis(u, n1, n2) for n1 in 0:N-1, n2 in 0:N-1]

params = SA_F64[1., -1., 0.5]
function duffing(u, p=params, t=0)
    α, β, δ = p
    x, dx = u
    SA_F64[
        dx, - δ*dx - x*(β+α*x^2)
    ]
end
function duffing(u::Point2{T}) where T
    v = SA_F64[u[1], u[2]]
    Point2f(duffing(v))
end

p2 = streamplot(duffing, -2..2, -2..2, colormap=:acton)
save("../figures/duffing_streamplot.pdf", p2)

tspan = (0., 0.1)
de = ODEProblem(duffing, SA_F64[0,0], tspan, params)

function initializer(de, i, repeat)
    de = deepcopy(de)
    de.u0 = nodes[i]
    de
end
returner(solution, i) = (solution[end], false)
ensemble_de = EnsembleProblem(de; prob_func=initializer, output_func=returner)

sim = with_logger(NullLogger()) do
    solve(ensemble_de; trajectories=M^2)
end

mapped_nodes = reshape(sim.u, (M,M))

ΨX = [ψ(u) for u in vec(nodes), ψ in vec(dictionary)]
ΨY = [ψ(u) for u in vec(mapped_nodes), ψ in vec(dictionary)]
W = Diagonal(vec(weights))

G = ΨX' * W * ΨX
A = ΨX' * W * ΨY
J = ΨY' * W * ΨY

function res(z, G=G, A=A, J=J)
    U = J - z' * A - z * A' + z'z * G
    ξ = real.( eigvals(U, G) )
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.02:1.2
z_grid = xs' .+ ys .* im

residuals = @showprogress map(res, z_grid)

λ, ev = eigen(A, G)

perm = sortperm(
    λ, by=x->abs(1-x)
)

λ = λ[perm]
ev = ev[:, perm]
ψ = permutedims(reshape( real.(ΨX * ev), (M,M,N^2) ), (2,1,3))
map!(scale, ψ, ψ)


p1 = plot(exp.(im .* (-π:0.001:π)), 
    style=:dash, aspectratio=1., leg=false, color=:blue
)
scatter!(λ, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=3, markerstrokewidth=1., 
    color=:purple
)
contour!(xs, ys, residuals, 
    colormap=:acton, linewidth=2,
    xlims=(-1.2,1.2), ylims=(-1.2,1.2),
    clabels=true, cbar=false,
    levels=0.05:0.1:0.35,
    clims=(0,0.4)
)

p = [
    contourf(
        2*_nodes, 2*_nodes, ψ[:, :, i], 
        leg=false, colormap=:berlin
    ) 
    for i in 1:20
]

clims = (minimum(ψ), maximum(ψ))
blank = plot(foreground_color_subplot=:white)
l = @layout [grid(2, 2) a{0.075w}]
plot(p1, p[2], p[3], p[7], blank, layout=l, link=:all)
p_all = scatter!(
    [NaN], [NaN], 
    zcolor=[NaN], 
    clims=clims, 
    label="", 
    c=:berlin, 
    colorbar_title="", 
    background_color_subplot=:transparent, 
    markerstrokecolor=:transparent, 
    framestyle=:none, 
    inset=bbox(0.0, 0, 0.6, 0.9, :center, :right), 
    subplot=6
)

savefig(p_all, "../figures/duffing_05.pdf")