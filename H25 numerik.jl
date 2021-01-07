using LinearAlgebra
using ForwardDiff: gradient, hessian

g(x) = (x[1]^2 + x[2] - 11)^2 + (x[1] + x[2]^2 - 7)^2  # Himmelblau function
f(x) = gradient(g,x)
Df(x) = hessian(g,x)

j, k, x, h, ĥ, τ = 0, 0, 10*rand(2).-5, [1,1], [0, 0], 1
while norm(h) > eps() && norm(ĥ) <= norm(h)
    Z = lu(Df(x))
    h = Z\f(x)
    x̂ = x - h
    ĥ = Z\f(x̂)
    while norm(ĥ) > norm(h)
        x̂ = x - 2.0^(-k-j) * h
        ĥ = Z\f(x̂)
        j += 1
    end
    x = x̂
    j = 0
    k += 1
    @show norm(f(x)), norm(h), norm(ĥ)
end
x, k, norm(ĥ) <= norm(h)
