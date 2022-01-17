using Plots, PlotThemes, LinearAlgebra
using ForwardDiff: derivative
theme(:dark)

g(x) = cos(2*π*x) * exp(- x^2 / 2)
a, b, n = -2, 2, 9

x = range(a, b, length=n+1)
h = [x[j+1] - x[j] for j in 1:n]
f = g.(x)
Df = [derivative(g, x[1]), derivative(g, x[n+1])]

λ = [1; 
     [h[j+1] / (h[j] + h[j+1]) for j in 1:n-1]
]
μ = [[h[j] / (h[j] + h[j+1]) for j in 1:n-1];
     1
]
d = [(((f[2] - f[1]) / h[1]) - Df[1]) * 6 / h[1];
     [( ((f[j+2] - f[j+1]) / h[j+1]) - ((f[j+1] - f[j]) / h[j]) ) * 6 / (h[j] + h[j+1]) for j in 1:n-1];
     (Df[2] - ((f[n+1] - f[n]) / h[n])) * 6 / h[n]
]
T = Tridiagonal(μ, ones(n+1).*2, λ)
M = T \ d

C = [((f[j+1] - f[j]) / h[j]) - ((M[j+1] - M[j]) * h[j] / 6) for j in 1:n]
D = [f[j] - (M[j] * h[j]^2 / 6) for j in 1:n]

s(z, j) = if x[j] ≤ z < x[j+1]
            (M[j] * (x[j+1] - z)^3 / (6 * h[j])) + (M[j+1] * (z - x[j])^3 / (6 * h[j])) + C[j] * (z - x[j]) + D[j]
          else
            0
          end
s(z) = sum(s(z, j) for j in 1:n)


y = range(a - 2, b + 2, length=1000)
plot(y, g.(y))
scatter!(x, g.(x))
plot!(y, s.(y))
#pushfirst!(λ, 1)push!(μ, 1)pushfirst!(d, (((f[2] - f[1]) / h[1]) - Df[1]) * 6 / h[1])
#push!(d, (Df[2] - ((f[n+1] - f[n]) / h[n])) * 6 / h[n])

