using Plots, PlotThemes, Distributions
import Distributions: pdf, logpdf, mean
theme(:dark)

mutable struct log2_Xn <: DiscreteUnivariateDistribution 
    n::Int64
    p::Float64
    log2_Xn(n, p) = new(n, p)
end
function pdf(dist::log2_Xn, m::Int64)
    iseven(dist.n) == iseven(m) ? m = m : m = m-1                       # alternatively: throw(ArgumentError("evenness doesn't match"))
    return pdf(Binomial(dist.n, dist.p), Real(floor((dist.n + m)/2)))     # @assert 0 <= m <= n "P(log2(Xn)==m) == 0, out of bounds"
end

mutable struct Xn <: DiscreteUnivariateDistribution
    n::Int64
    p::Float64
    Xn(n, p) = new(n, p)
end
function pdf(dist::Xn, m::Real)
    m = Int(floor(log2(m)))
    return pdf(log2_Xn(dist.n, dist.p), m)
end
function logpdf(dist::Xn, m::Real)
    return log(pdf(dist, m))
end
function E(dist::Xn)
    E = 0
    for m in range(1e-3, 16+1e-3, length=160)
        E += m * pdf(dist, m)
    end
    return E
end

n = 1:1000
p = range(1/3, 1/2, length=100)
X = [E(Xn(n[i], p[j])) for i in 1:1000, j in 1:100]

anim = @animate for m in 1:100
    scatter(n, X[1:1000, m], xaxis=("n", :log10), yaxis=("E(Xn)", (0,350)), label="p = $(p[m])")
end
gif(anim, fps=20)