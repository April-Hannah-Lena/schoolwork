using Polynomials, LinearAlgebra

T_(n, x) = ChebyshevT([zeros(n); 1])(x)

n = 10
x = rand(n)
f = rand(n)

P = [T_(ni, xi) for xi in x, ni in 1:n]

p = P\f
c = cond(P)

println("coeffs = "); display(p)
println("κ = "); display(c)