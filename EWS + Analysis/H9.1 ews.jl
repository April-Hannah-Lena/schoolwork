using Plots, PlotThemes, Distributions, Roots
import Distributions: pdf
using Pipe: @pipe
theme(:dark)


mutable struct Ei <: DiscreteMultivariateDistribution
    λ::Float64
    p::Float64
end

function pdf(dist::Ei, m::Int64)
    ρ, j, q= 0, m, 1-dist.p
    #Q = exp(-dist.λ) * dist.p^m * (1-dist.p)^(-m) / factorial(m)

    E = Poisson(dist.λ)
    while pdf(E, j) > sqrt(eps())
        #ρ += Q * dist.λ^j * q^j / factorial(j-m)
        ρ = pdf(E, j) * pdf(Binomial(j, dist.p), m)
        j += 1
    end
    return ρ
end


ms = 1:30
λs = 0.0:0.1:30.0
ps = 0.0:1/300:1.0
P_λp = [pdf(Ei(λ, p), m) for λ in λs, p in ps, m in ms]
rescaleP_λp = P_λp .* 1e148; maximum(rescaleP_λp)
#inds = rescaleP_λp .== -Inf; rescaleP_λp[inds] .= Inf

anim = @animate for i in ms
    heatmap(λs, ps, rescaleP_λp[:, :, i], 
            yflip=true, 
            xlabel="p", ylabel="λ", title="m = $i", 
            colorbar_title="P(S = m)")
end
gif(anim, fps=15)


p1, λ1 = 0.5, 1

function difference(λ1, p1, λ2, p2, k)
    e(λ, p, κ) = exp(-λ*p) * ((p/λ)^κ)
    return e(λ1, p1, k) - e(λ2, p2, k)
end

differences = [difference(λ1, p1, λ2, p2, m) for λ2 in λs, p2 in ps, m in ms]
Infs = (differences .== Inf) .+ (differences .== -Inf)
differences[Infs] .= 0

anim2 = @animate for m in ms
    surface(λs, ps, differences[:, :, m], 
            zlims=(-10, 10), 
            title="P_λ1,p1(S = m) - P_λ2,p2(S = m), m = $m")
end
gif(anim2, fps=15)