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
    c = f ≤ length(c) ? c[f] : 0
    d = big(5.) ^ big(y)
    return Float64(c / d)
end
scatter(1:250, [f -> dsumunif_discrete(f, y) for y in 1:5:100])

dbinom(n, f) = pdf(Binomial(f, 0.5), n)
scatter(1:75, [n -> dbinom(n, f) for f in 1:5:100])

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
scatter(1:100, [n -> dblazerods(n, x) for x in 1:50:500])