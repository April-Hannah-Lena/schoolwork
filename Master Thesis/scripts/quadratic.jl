using LinearAlgebra, Statistics
using FastGaussQuadrature, LegendrePolynomials
using Plots, ProgressMeter

S(x) = 4x*(1-x)

τ(x) = 2x-1
τ⁻¹(x) = (x+1)/2

M = 100
nodes, weights = gausslegendre(M)

N = 40
dictionary = [x -> Pl(x, degree, norm=Val(:normalized)) for degree in 0:N-1]

ΨX = [ψ(x) for x in nodes, ψ in dictionary]
ΨY = [(ψ ∘ τ∘S∘τ⁻¹)(x) for x in nodes, ψ in dictionary]
W = Diagonal(weights)

G = ΨX' * W * ΨX
A = ΨX' * W * ΨY

λ_K, V_K = eigen(A, G)
λ_L, V_L = eigen(A', G)

p1 = plot(exp.(im .* (-π:0.001:π)), 
    style=:dash, aspectratio=1., leg=false, color=:blue
)
scatter!(λ_K, marker=:+, xlabel="", ylabel="", markersize=7, markerstrokewidth=3, color=:chocolate1)

v_K = real.(V_K[:, end])
ψ_K(x) = v_K' * [ ψ(x) for ψ in dictionary ]

@assert std(ψ_K.(-1:0.01:1)) < 0.01

p2 = plot(0:0.001:1, x->1, linewidth=2, leg=false, ylims=(0,4))

v_L = real.(V_L[:, end])
v_L .*= -1
ψ_L(x) = v_L' * [ ψ(x) for ψ in dictionary ]

p3 = plot(0:0.001:1, τ⁻¹ ∘ ψ_L ∘ τ, ylims=(0,4), linewidth=2, leg=false)

p = plot(p1, p2, p3, layout=(1,3), size=(900,300))

savefig("../figures/edmd.pdf")


J = ΨY' * W * ΨY

function res(z, G=G, A=A, J=J)
    U = J - z' * A - z * A' + z'z * G
    ξ = real.( eigvals(U, G) )
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.01:1.2
grid = xs' .+ ys .* im

residuals = @showprogress map(res, grid)

p4 = contour(xs, ys, residuals, 
    colormap=:acton, linewidth=2, size=(400,400),
    clabels=true, cbar=false,
    levels=0:0.1:1
)
plot!(exp.(im .* (-π:0.001:π)), 
    style=:dash, aspectratio=1., leg=false, color=:blue
)
scatter!(λ_K, marker=:+, xlabel="", ylabel="", markersize=7, markerstrokewidth=3, color=:chocolate1)

savefig(p4, "../figures/resdmd.pdf")