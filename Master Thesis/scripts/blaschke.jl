using LinearAlgebra
using Plots, ProgressMeter, Base.Threads
using FFTW, FFTViews

r = 0.79
μ = 0.75*exp(2π*im/8)
S(z, μ=μ) = z * (z - μ) / (1 - μ'z)

λ_true = vec( [(-μ) (-μ)'] .^ (0:50) )

M = 1_000
dθ = 1/M
θs = dθ:dθ:1
circ = exp.(2π*im .* θs)

basis(z, n) = z^n
basis(n) = z -> z^n

N = 10
dictionary = basis.(-N:N)

ΨX = [ψ(z) for z in circ, ψ in dictionary]
ΨY = [ψ(S(z)) for z in circ, ψ in dictionary]

W = UniformScaling(1/M)

G = ΨX' * W * ΨX
A = ΨX' * W * ΨY
J = ΨY' * W * ΨY

function res(z, G=G, A=A, J=J)
    U = J - z' * A - z * A' + z'z * G
    ξ = real.( eigvals(U, G) )
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.01:1.2
grid = xs' .+ ys .* im

residuals = @showprogress map(res, grid)

λ, ev = eigen(A, G)


p1 = plot(circ, 
    style=:dash, aspectratio=1., leg=false, color=:blue, size=(400,400)
)
scatter!(λ, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=2
)
scatter!(λ_true, 
    marker=:x, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=3
)
contour!(xs, ys, log10.(residuals.+1e-20), 
    colormap=:acton, linewidth=2,
    clabels=true, cbar=false,
    levels=[-0.5:0.1:0; -1;],
    clims=(-1,0)
)

savefig(p1, "../figures/blaschke_direct.pdf")


k(x, y, c=0.01) = exp(-abs2(x-y) / c)

Ĝ = [k(xj, xk) for xj in circ, xk in circ]
Â = [k(S(yj), xk) for yj in circ, xk in circ]
Ĵ = [k(S(yj), S(yk)) for yj in circ, yk in circ]

σ, Q = eigen(Ĝ)
r̂ = 50#sum(σ .> 1e-4)

Σ̂ = Diagonal( sqrt.(σ[end-r̂+1:end]) )
Q̂ = Q[:, end-r̂+1:end]

Σ̂⁺ = inv(Σ̂)
K̂ = (Σ̂⁺*Q̂') * Â * (Q̂*Σ̂⁺)
M̂ = (Q̂*Σ̂⁺)' * Ĵ * (Q̂*Σ̂⁺)

residualŝ = @showprogress map(z->res(z, I(r̂), K̂, M̂), grid)

λ̂, ev̂ = eigen(K̂)

p2 = plot(circ, 
    style=:dash, aspectratio=1., leg=false, color=:blue, size=(400,400)
)
contour!(xs, ys, log10.(residualŝ.+1e-20), 
    colormap=:acton, linewidth=2, 
    clabels=true, cbar=false,
    levels=[-5:1:0; -0.5;],
    clims=(-5,1)
)
scatter!(λ̂, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=2
)
scatter!(λ_true, 
    marker=:x, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=3
)

savefig(p2, "../figures/blaschke_kernel.pdf")


G̃ = zeros(ComplexF64, 2N+1, 2N+1)
Ã = zeros(ComplexF64, 2N+1, 2N+1)
J̃ = zeros(ComplexF64, 2N+1, 2N+1)

prog = Progress(length(G), desc="Computing matrices...")
@threads for cartesian in CartesianIndices(G̃)
    i, j = cartesian.I
    zi, zj = zeros(ComplexF64, M), zeros(ComplexF64, M)
    ffti, fftj = zeros(ComplexF64, M), zeros(ComplexF64, M)

    ψi = basis( (-N:N)[i] )
    ψj = basis( (-N:N)[j] )
    
    zi .= ψi.(circ)
    zj .= ψj.(circ)
    ffti .= fft(zi) ./ M
    fftj .= fft(zj) ./ M
    vi, vj = FFTView(ffti), FFTView(fftj)

    G̃[i,j] = sum(-250:250) do m
        vi[m]' * vj[m] * r^(2abs(m))
    end 

    zj .= (ψj ∘ S).(circ)
    fftj .= fft(zj) ./ M
    vj = FFTView(fftj)

    Ã[i,j] = sum(-250:250) do m
        vi[m]' * vj[m] * r^(2abs(m))
    end 

    zi .= (ψi ∘ S).(circ)
    ffti .= fft(zi) ./ M
    vi = FFTView(ffti)

    J̃[i,j] = sum(-250:250) do m
        vi[m]' * vj[m] * r^(2abs(m))
    end 

    next!(prog)
end


residuals̃ = @showprogress map(z->res(z, G̃, Ã, J̃), grid)

λ̃, eṽ = eigen(A, G)


p3 = plot(circ, 
    style=:dash, aspectratio=1., leg=false, color=:blue, size=(400,400)
)
contour!(xs, ys, log10.(residuals̃.+1e-20), 
    colormap=:acton, linewidth=2,
    clabels=true, cbar=false,
    levels=-2:0.2:0,
    clims=(-1.2,0)
)
scatter!(λ̃, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=2
)
scatter!(λ_true, 
    marker=:x, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=3
)


savefig(p3, "../figures/blaschke_hardy.pdf")

p = plot(p1, p2, p3, layout=(1,3), size=(900,300))

savefig(p, "../figures/blasckhe_comaprison.pdf")


using Polynomials, FastGaussQuadrature, LegendrePolynomials

M = 1_000
dθ = 1/M
θs = -1+dθ:dθ:1
circ = exp.(π*im .* θs)

N = 40

basis(θ, n) = Pl(θ, n, norm=Val(:normalized))
basis(n) = θ -> basis(θ, n)

dictionary = basis.(0:N-1)

nodes, weights = gausslegendre(M)

ΨX = [ψ(θ) for θ in nodes, ψ in dictionary]
ΨY = [ψ( angle(S(exp(π*im*θ)))/π ) for θ in nodes, ψ in dictionary]

W = Diagonal(weights)

G = ΨX' * W * ΨX
A = ΨX' * W * ΨY
J = ΨY' * W * ΨY

function res(z, G=G, A=A, J=J)
    U = J - z' * A - z * A' + z'z * G
    ξ = real.( eigvals(U, G) )
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.01:1.2
grid = xs' .+ ys .* im

residuals = @showprogress map(res, grid)

λ, ev = eigen(A, G)


p4 = plot(circ, 
    style=:dash, aspectratio=1., leg=false, color=:blue, size=(400,400)
)
scatter!(λ, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=2
)
scatter!(λ_true, 
    marker=:x, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=3
)
contour!(xs, ys, log10.(residuals.+1e-20), 
    color=:acton, linewidth=2,
    clabels=true, cbar=false,
    levels=[-0.5:0.1:0; -1;],
    clims=(-0.4,0),
    alpha=0.8
)

savefig(p4, "../figures/blaschke_legendre.pdf")