using LinearAlgebra

function T(f, a, b, h)
    I = 0
    x = a + h
    f₀ = f(a)
    while x < b
        f₁ = f(x)
        I += h * (f₀ + f₁) / 2
        f₀ = f₁
        x += min(h, b-x)
    end
    return I
end

function Romberg(f, a, b, n)
    h = [0.5^k for k in 0:n-1]
    p = LowerTriangular(zeros(n, n))
    p[:, 1] = T.(f, a, b, h)
    for j in 1:n, k in 2:j
        p[j, k] = p[j, k-1] + ( (p[j, k-1] - p[j-1, k-1]) / (4^k - 1) )
    end
    return p[n, n]
end

using RCall
f(x) = exp(- x^2 / 2) / sqrt(2 * π)
I = R"pnorm(pi) - pnorm(0)" |> rcopy
Ĩ = [Romberg(f, 0, float(π), n) for n in 1:16]
ϵ = @. (I - Ĩ) / I