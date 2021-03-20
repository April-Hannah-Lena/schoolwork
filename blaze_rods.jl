using Distributions, SpecialFunctions, Polynomials
using Plots, PlotThemes
theme(:dark)

function psumunif(x, n)
    x̲ = Int(floor(x))
    n = BigInt(n)       # convert to BigInt to avoid 
    k = BigInt.(0:x̲)    # Int64 overflows with gamma(n+1)
    P = @. (-1)^k * binomial(n, k) * (x-k)^n
    P = sum(P) / gamma(n+1)
    return Float64(P)   # convert back, Float64 uses less storage
end
plot(0:0.1:6, [x -> psumunif(x, n) for n in 1:6])
psumunif(x, n, diff) = diff == true ? psumunif(x, n) - psumunif(x, n+1) : psumunif(x, n)
plot(0:0.1:12, [x -> psumunif(x, n, true) for n in 1:6])

function dsumunif_discrete(f, y)
    f = Int(floor(f))
    P = Polynomial(ones(5))^y
    c = big.(coeffs(P))
    c = f ≤ length(c) ? c[f] : 0.
    d = big(5.) ^ big(y)
    return Float64(c / d)
end
scatter(1:250, [f -> dsumunif_discrete(f, y) for y in 1:5:100])

dbinom(n, f) = pdf(Binomial(f, 0.5), n)
scatter(1:75, [n -> dbinom(n, f) for f in 1:5:100])
pbinom(n, f) = ccdf(Binomial(f, 0.5), n)

function dblazerods_support(x, f)
    z = (x-10)/30
    m, M = Int.(floor.([x/40, x/10]))
    P = @. dsumunif_discrete(f, m:M) * psumunif(z, m:M, true)
    return sum(P)
end
function dblazerods(n, x)
    c = Int.(floor.(2 * x / 5))
    P = @. dbinom(n, 1:c) * dblazerods_support(x, 1:c)
    return sum(P)
end
using ProgressMeter
xs = 10:10:500; ns = 0:2:10
ys = Array{Float64, 2}(undef, 0, length(ns))
@showprogress 1 "Computing...  " for x in xs
    ys = vcat(ys, dblazerods.(ns, x)')
end
plot(xs, [ys[:, n] for n in 1:length(ns)], leg=false, xaxis=:log10)

function pblazerods(n, x)
    c = Int.(floor.(2 * x / 5))
    P = @. pbinom(n, 1:c) * dblazerods_support(x, 1:c)
    return sum(P)
end
xs = 10:10:500; ns = 0:2:10
ys = Array{Float64, 2}(undef, 0, length(ns))
@showprogress 1 "Computing...  " for x in xs
    ys = vcat(ys, pblazerods.(ns, x)')
end
fig = plot(xs, [ys[:, n] for n in 1:length(ns)], 
    title="Probability of getting > n heads after x seconds",
    xaxis=("seconds, scaled logarithmically", :log10), 
    yaxis="P(heads flipped > n)", 
    leg=:bottomright,
    legendtitle="n",
    lab=ns')
savefig(fig, "blaze_rods.png")

using FastGaussQuadrature, LinearAlgebra
xs, w = gausslegendre(80)
a, b = 10, 800
xs = @. 0.5*(b-a)*(xs+1) + a
ns = 0:2:10
ys = Array{Float64, 2}(undef, 0, length(ns))
@showprogress 1 "Computing...  " for x in xs
    ys = vcat(ys, x .* dblazerods.(ns, x)')
end
E = [w' * ys[:, n] for n in 1:length(ns)]
E = (b-a) .* E ./ 2
using DataFrames, CSV
expected_time_n = DataFrame("nr. of heads" => ns, 
                            "expected time (s)" => E, 
                            "expected time (min)" => E./60)
CSV.write("/u/halle/herwiga/home_at/Documents/schoolwork/blaze_rods.csv", expected_time_n)