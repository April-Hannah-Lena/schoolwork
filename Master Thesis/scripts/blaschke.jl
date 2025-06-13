using LinearAlgebra
using Polynomials, FastGaussQuadrature, LegendrePolynomials
using Plots, LaTeXStrings, Colors, Measures, ProgressMeter, Base.Threads
using FFTW, FFTViews

default(fontfamily="Computer Modern", framestyle=:box)

r = 0.755
μ = -0.33*exp(2π*im/200)
#μ = 0.75*exp(2π*im/8)
#S(z, μ=μ) = z * (z - μ) / (1 - μ'z)
#λ_true = vec( [(-μ) (-μ)'] .^ (0:50) )

S(z, μ=μ) = ((z - μ) * (z - μ)) / ((1 - μ'z)*(1 - μ'z))

kappa = 0.9311625603 + 0.0974629293*im
λ_true = vec( [kappa kappa'] .^ (0:50) )


function res(z, G, A, J)
    U = J - z' * A - z * A' + z'z * G
    ξ = real.( eigvals(U, G) )
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.02:1.2
grid = xs' .+ ys .* im

M = 1_000
dθ = 1/M
θs = dθ:dθ:1
circ = exp.(2π*im .* θs)

k(x, y, c=0.01) = exp(-abs2(x-y) / c)
#k(x, y) = 1 / (1 - x'y * r^2)
#k(x, y, s=0) = sum((x^k)' * (y^k) / (1 + abs2(k))^s for k in -40:40)

ξ = exp(2π*im/(2M))
Ĝ = [k(xj, xk) for xj in [circ; 0.85*ξ .* circ; 1.15/ξ .* circ], xk in [circ; 0.85*ξ .* circ; 1.15/ξ .* circ]] / (3M)
Â = [k(S(yj), xk) for yj in [circ; 0.85*ξ .* circ; 1.15/ξ .* circ], xk in [circ; 0.85*ξ .* circ; 1.15/ξ .* circ]] / (3M)
Ĵ = [k(S(yj), S(yk)) for yj in [circ; 0.85*ξ .* circ; 1.15/ξ .* circ], yk in [circ; 0.85*ξ .* circ; 1.15/ξ .* circ]] / (3M)

σ, Q = eigen(Ĝ)
r̂ = 200#sum(σ .> 1e-4)

Σ̃ = Diagonal( sqrt.(σ[end-r̂+1:end]) )
Q̃ = Q[:, end-r̂+1:end]

G̃ = Q̃' * Ĝ * Q̃
Ã = Q̃' * Â * Q̃
J̃ = Q̃' * Ĵ * Q̃

K̂ = (inv(Σ̃) * Q̃') * Â * (Q̃ * inv(Σ̃))

residualŝ = @showprogress map(z->res(z, G̃, Ã, J̃), grid)

λ̂, ev̂ = eigen(K̂)

p2 = plot(circ, 
    style=:dash, aspectratio=1., leg=false, color=:blue, size=(550,500),
    #title="Kernel ResDMD"
)
contour!(xs, ys, log10.(residualŝ.+1e-20), 
    colormap=:acton, linewidth=2, 
    clabels=true, cbar=true,
    levels=[-8:1:0; -0.2;],
    clims=(-8.1,1),
    alpha=0.8
)
scatter!(λ_true, 
    marker=:circle, 
    xlabel="", ylabel="", 
    markersize=4.5, markerstrokewidth=2, 
    color=:black,
    markeralpha=0.8, 
    #lab="True (Hardy space) eigs"
)
scatter!(λ̂, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=8, markerstrokewidth=2.5, 
    color=2,
    markeralpha=0.9,
    #lab="computed eigs"
)
contourf!(
    xs, ys, fill(NaN, length(xs), length(ys)),
    xlims=(-1.2,1.2), ylims=(-1.2,1.2),
    colormap=:acton, linewidth=2,
    clims=(-5.1,0),
    alpha=0.8,
    rightmargin=4mm,
    xlabel=L"Re (\lambda)", ylabel=L"Im (\lambda)", 
)

savefig(p2, "../figures/blaschke_kernel.pdf")


basis(z, n) = z^n
basis(n) = z -> z^n

M = 10_000
N = 60
dictionary = basis.(-N:N)

ΨX = [ψ(z) for z in circ, ψ in dictionary]
ΨY = [ψ(S(z)) for z in circ, ψ in dictionary]

W = UniformScaling(1/M)

G = ΨX' * W * ΨX
A = ΨX' * W * ΨY
J = ΨY' * W * ΨY

residuals = @showprogress map(z->res(z, G, A, J), grid)

λ, ev = eigen(A, G)


p1 = plot(circ, 
    style=:dash, aspectratio=1., leg=false, color=:blue, size=(450,400),
    title="Fourier Dictionary"
)
contour!(xs, ys, log10.(residuals.+1e-20), 
    colormap=:acton, linewidth=2,
    clabels=true, cbar=true,
    levels=[-1:0.05:0;],
    clims=(-1,0),
    alpha=0.8
)
scatter!(λ_true, 
    marker=:circle, 
    xlabel="", ylabel="", 
    markersize=4.5, markerstrokewidth=2, 
    color=:black,
    markeralpha=0.8, 
)
scatter!(λ, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=8, markerstrokewidth=2.5, 
    color=2,
    markeralpha=0.9,
    #lab="computed eigs"
)
contourf!(
    xs, ys, fill(NaN, length(xs), length(ys)),
    xlims=(-1.2,1.2), ylims=(-1.2,1.2),
    colormap=:acton, linewidth=2,
    clims=(-0.8,0),
    alpha=0.8,
    rightmargin=4mm,
    xlabel=L"Re (\lambda)", ylabel=L"Im (\lambda)", 
)

savefig(p1, "../figures/blaschke_direct.pdf")


M = 10_000
dθ = 1/M
θs = dθ:dθ:1
circ = exp.(2π*im .* θs)

#_G = copy(diag(G̃))
#dictionary = [z -> z^n / sqrt(_G[n+N+1]) for n in -N:N]

G̃ = zeros(ComplexF64, 2N+1, 2N+1)
Ã = zeros(ComplexF64, 2N+1, 2N+1)
J̃ = zeros(ComplexF64, 2N+1, 2N+1)

prog = Progress(length(G̃), desc="Computing matrices...")
@threads for cartesian in CartesianIndices(G̃)
    i, j = cartesian.I
    zi, zj = zeros(ComplexF64, M), zeros(ComplexF64, M)
    ffti, fftj = zeros(ComplexF64, M), zeros(ComplexF64, M)

    ψi = dictionary[i]
    ψj = dictionary[j]
    
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

λ̃, eṽ = eigen(Ã, G̃)


p3 = plot(circ, 
    style=:dash, aspectratio=1., leg=false, color=:blue, size=(450,400),
    title=L"Hardy Space $H^2 (A)$"
)
contour!(xs, ys, log10.(residuals̃.+1e-20), 
    colormap=:acton, linewidth=2,
    clabels=true, cbar=true,
    levels=[-4:1:0; -0.1; -3.5; -0.5],
    #levels=-6:0.4:0,
    clims=(-4.1,0),
    alpha=0.8
)
scatter!(λ_true, 
    marker=:circle, 
    xlabel="", ylabel="", 
    markersize=4.5, markerstrokewidth=2, 
    color=:black,
    markeralpha=0.6, 
    #lab="True (Hardy space) eigs"
)
scatter!(λ̃, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=8, markerstrokewidth=2.5, 
    color=2,
    markeralpha=0.8,
    #lab="computed eigs"
)
contourf!(
    xs, ys, fill(NaN, length(xs), length(ys)),
    xlims=(-1.2,1.2), ylims=(-1.2,1.2), 
    #xlims=(0.7,1.1), ylims=(-0.2,0.2), 
    colormap=:acton, linewidth=2,
    clims=(-4.1,0),
    alpha=0.8,
    rightmargin=4mm,
    xlabel=L"Re (\lambda)", ylabel=L"Im (\lambda)", 
)

savefig(p3, "../figures/blaschke_other_hardy.pdf")

#p = plot(p1, p2, p3, layout=(1,3), size=(900,300))

#savefig(p, "../figures/blasckhe_comaprison.pdf")



M = 10_000
dθ = 1/M
θs = -1+dθ:dθ:1
circ = exp.(π*im .* θs)

N = 120

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

residuals = @showprogress map(z->res(z, G, A, J), grid)

λ, ev = eigen(A, G)


p4 = plot(circ, 
    style=:dash, aspectratio=1., leg=false, color=:blue, size=(450,400),
    title="Legendre Polynomial Dictionary"
)
contour!(xs, ys, log10.(residuals.+1e-20), 
    color=:acton, linewidth=2,
    clabels=true, cbar=true,
    levels=[-0.5:0.1:0; -1;],
    clims=(-0.4,0),
    alpha=0.8
)
scatter!(λ_true, 
    marker=:circle, 
    xlabel="", ylabel="", 
    markersize=4.5, markerstrokewidth=2, 
    color=:black,
    markeralpha=0.8, 
    #lab="True (Hardy space) eigs"
)
scatter!(λ, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=8, markerstrokewidth=2.5, 
    color=2,
    markeralpha=0.9,
    #lab="computed eigs"
)
contourf!(
    xs, ys, fill(NaN, length(xs), length(ys)),
    xlims=(-1.2,1.2), ylims=(-1.2,1.2),
    colormap=:acton, linewidth=2,
    clims=(-0.4,0),
    alpha=0.8,
    rightmargin=4mm,
    xlabel=L"Re (\lambda)", ylabel=L"Im (\lambda)", 
)


savefig(p4, "../figures/blaschke_legendre.pdf")


M = 40_000
dθ = 1/M
θs = dθ:dθ:1
circ = exp.(2π*im .* θs)

N = 22

#ss = -8:0.1:5
s = -4.

basis(z, n) = z^n  *  (1 + n^2)^(-s/2)
basis(n) = z -> z^n

#_G = copy(G̃)
#basis(n) = z -> z^n / sqrt(_G[n+N+1, n+N+1])

dictionary = basis.(-N:N)

G̃ = zeros(ComplexF64, 2N+1, 2N+1)
Ã = zeros(ComplexF64, 2N+1, 2N+1)
J̃ = zeros(ComplexF64, 2N+1, 2N+1)

#prog = Progress(length(ss))
#anim = @animate for s in ss

    #prog = Progress(length(G̃), desc="Computing matrices...")
    @threads for cartesian in CartesianIndices(G̃)
        i, j = cartesian.I
        zi, zj = zeros(ComplexF64, M), zeros(ComplexF64, M)
        ffti, fftj = zeros(ComplexF64, M), zeros(ComplexF64, M)

        ψi = dictionary[i]
        ψj = dictionary[j]
        
        zi .= ψi.(circ)
        zj .= ψj.(circ)
        ffti .= fft(zi) ./ M
        fftj .= fft(zj) ./ M
        vi, vj = FFTView(ffti), FFTView(fftj)

        G̃[i,j] = sum(-2N:2N) do m
            vi[m]' * vj[m] * (1 + m^2)^s
        end 

        zj .= (ψj ∘ S).(circ)
        fftj .= fft(zj) ./ M
        vj = FFTView(fftj)

        Ã[i,j] = sum(-2N:2N) do m
            vi[m]' * vj[m] * (1 + m^2)^s
        end 

        zi .= (ψi ∘ S).(circ)
        ffti .= fft(zi) ./ M
        vi = FFTView(ffti)

        J̃[i,j] = sum(-2N:2N) do m
            vi[m]' * vj[m] * (1 + m^2)^s
        end 

        #next!(prog)
    end

    # H^s matrix transponieren und dann mal H^-s matrix

    residuals̃ = @showprogress map(z->res(z, G̃, Ã, J̃), grid)

    λ̃, eṽ = eigen(Ã, G̃)

    #next!(prog)


    p5 = plot(circ, 
        style=:dash, aspectratio=1., leg=false, color=:blue, size=(450,400),
        title=L"Sobolev Space $H^{-4}$"
    )
    contour!(xs, ys, #=residuals̃,=#log10.(residuals̃.+1e-20), 
        colormap=:acton, linewidth=2,
        clabels=true, cbar=true,
        levels=[-4:0.25:-3.5; -3:0.5:0; -0.2; -0.1; -0.00001],
        clims=(-4,0),
        #title="residuals in H^$s",
        leg=false,
        alpha=0.7,
        #colorbar_title="log-scaled residuals"
    )
    scatter!(λ_true, 
        marker=:circle, 
        xlabel="", ylabel="", 
        markersize=4.5, markerstrokewidth=2, 
        color=:black,
        markeralpha=0.8, 
        #lab="True (Hardy space) eigs"
    )
    scatter!(λ̃, 
        marker=:+, 
        xlabel="", ylabel="", 
        markersize=8, markerstrokewidth=2.5, 
        color=2,
        markeralpha=0.9,
        #lab="computed eigs"
    )
    contourf!(
        xs, ys, fill(NaN, length(xs), length(ys)),
        xlims=(-1.2,1.2), ylims=(-1.2,1.2),
        #xlims=(0.6,1.1), ylims=(-0.25,0.25), 
        colormap=:acton, linewidth=2,
        #clims=(-1.8,0),
        alpha=0.8,
        rightmargin=4mm,
        xlabel=L"Re (\lambda)", ylabel=L"Im (\lambda)", 
    )
    lens!(
        [0.6, 1.05], [-0.35, 0.35], 
        inset = (1, bbox(0.05, 0.05, 0.28, 0.42)), 
        levels=[-4:0.25:-3.5; -3:0.5:0; -0.2; -0.1; -0.00001],
        cbar=false, clabels=false, 
        clims=(-4,0), 
        tickfontcolor=RGBA(0.,0.,0.,0.)
    )

    savefig(p5, "../figures/blaschke_other_H-4.pdf")


#end

#mp4(anim, fps=5)



function normality(s)
    dictionary = basis.(-N:N)

    G = zeros(ComplexF64, 2N+1, 2N+1)
    A = zeros(ComplexF64, 2N+1, 2N+1)
    J = zeros(ComplexF64, 2N+1, 2N+1)

    #prog = Progress(length(G̃), desc="Computing matrices...")
    @threads for cartesian in CartesianIndices(G)
        i, j = cartesian.I
        zi, zj = zeros(ComplexF64, M), zeros(ComplexF64, M)
        ffti, fftj = zeros(ComplexF64, M), zeros(ComplexF64, M)

        ψi = dictionary[i]
        ψj = dictionary[j]
        
        zi .= ψi.(circ)
        zj .= ψj.(circ)
        ffti .= fft(zi) ./ M
        fftj .= fft(zj) ./ M
        vi, vj = FFTView(ffti), FFTView(fftj)

        G[i,j] = sum(-15:15) do m
            vi[m]' * vj[m] * (1 + m^2)^s
        end 

        zj .= (ψj ∘ S).(circ)
        fftj .= fft(zj) ./ M
        vj = FFTView(fftj)

        A[i,j] = sum(-15:15) do m
            vi[m]' * vj[m] * (1 + m^2)^s
        end 

        zi .= (ψi ∘ S).(circ)
        ffti .= fft(zi) ./ M
        vi = FFTView(ffti)

        J[i,j] = sum(-15:15) do m
            vi[m]' * vj[m] * (1 + m^2)^s
        end 

        #next!(prog)
    end


    _G = copy(diag(G))
    dictionary = [z -> z^n / sqrt(_G[n+N+1]) for n in -N:N]


    fill!(G, 0)
    fill!(A, 0)
    fill!(J, 0)

    @threads for cartesian in CartesianIndices(G)
        i, j = cartesian.I
        zi, zj = zeros(ComplexF64, M), zeros(ComplexF64, M)
        ffti, fftj = zeros(ComplexF64, M), zeros(ComplexF64, M)

        ψi = dictionary[i]
        ψj = dictionary[j]
        
        zi .= ψi.(circ)
        zj .= ψj.(circ)
        ffti .= fft(zi) ./ M
        fftj .= fft(zj) ./ M
        vi, vj = FFTView(ffti), FFTView(fftj)

        G[i,j] = sum(-15:15) do m
            vi[m]' * vj[m] * (1 + m^2)^s
        end 

        zj .= (ψj ∘ S).(circ)
        fftj .= fft(zj) ./ M
        vj = FFTView(fftj)

        A[i,j] = sum(-15:15) do m
            vi[m]' * vj[m] * (1 + m^2)^s
        end 

        zi .= (ψi ∘ S).(circ)
        ffti .= fft(zi) ./ M
        vi = FFTView(ffti)

        J[i,j] = sum(-15:15) do m
            vi[m]' * vj[m] * (1 + m^2)^s
        end 

        #next!(prog)
    end


    norm(A * A'  -  A' * A) / ( norm(A) * norm(A') )
end

s_range = -12.0:0.2:0.0
norms = @showprogress map(normality, s_range)

plot(
    s_range, norms,
    size=(500,400), 
    lab=false, 
    linewidth=2.5, 
    xlabel=L"s", 
    ylabel=L"\Vert L K - K L \,\Vert_{op}\ /\ ( \Vert L K \,\Vert_{op} + \Vert K L \,\Vert_{op} )",
    xticks=[-12:2:0;],
    yticks=10 .^ (-1.4:0.2:-0.4),
    yscale=:log10,
)
plot!(
    s_range, x -> 0.5exp(x / 5), 
    style=:dash, 
    linewidth=2,
    yscale=:log10,
    color=:purple, 
    lab=false,
)
annotate!(-2, 10^(-0.65), (L"O(e^{s/5})", :purple, :center))
