using ToeplitzMatrices, LinearAlgebra
using Plots, LaTeXStrings, ColorSchemes, ProgressMeter

N = 40

M = Toeplitz(
    [0.; 1.; zeros(N-2)],
    [0.; 0.; 0.25; zeros(N-3)]
)

function residual(z, M)
    A = M'M - z*M' - z'*M + z'z*I
    λ = minimum(real, eigvals(A))
    λ < -50*eps() && @warn "erroneous negative residual calculated" z λ
    max(λ, 5*eps())
end

xs = -1.0:0.01:1.6
ys = -1.3:0.01:1.3
grid = xs' .+ ys .* im
pseudospec_contours = @showprogress broadcast(z->residual(z, M), grid)

gradient = cgrad(:acton, alpha=0.2)

function err_eigs(ϵ=1e-1, M=M)
    N = size(M, 1)
    E = randn(N,N)
    E .*= rand()*ϵ/norm(E)
    ComplexF64.(eigvals(M+E))
end

sample_eigs = vcat([err_eigs(1e-1) for _ in 1:40]...)

begin
p = scatter(
    sample_eigs, 
    color=:indigo, 
    markeralpha=0.3, 
    markersize=1.5, 
    markerstrokewidth=0, 
    label=false
)

contour!(
    xs, ys, log10.(pseudospec_contours),
    color=gradient,
    linewidth=2,
    levels=5,
    clabels=true,
    cbar=false,
    clims=(-12,0)
)

scatter!(
    eigvals(M), 
    color=:black, 
    markersize=2.8, 
    markerstrokewidth=0, 
    label=false, 
    xlabel="", 
    ylabel=""
)
end

savefig(p, "../figures/pseudospectrum_rand.pdf")
