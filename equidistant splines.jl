using Plots, PlotThemes, LinearAlgebra, LaTeXStrings
using ForwardDiff: derivative
theme(:dark)

D(f) = x -> derivative(f, x)
D(f, n) = n > 1 ? D(D(f), n-1) : D(f)
function equidistant_spline(g, a, b, n)
    x = range(a, b, length=n+1)
    h = x[2] - x[1]
    f = g.(x)
    Df = D(g).([x[1], x[n+1]])
  
    λ = [1; 0.5 .* ones(n-1)]
    μ = reverse(λ)
    γ = 2 .* ones(n+1)
    d = [(((f[2] - f[1]) / h) - Df[1]) * 6 / h;
         [( ((f[j+2] - f[j+1]) / h) - ((f[j+1] - f[j]) / h) ) * 3 / h for j in 1:n-1];
         (Df[2] - ((f[n+1] - f[n]) / h)) * 6 / h]
    T = Tridiagonal(μ, γ, λ)
    M = T \ d
  
    C = [((f[j+1] - f[j]) / h) - ((M[j+1] - M[j]) * h / 6) for j in 1:n]
    G = [f[j] - (M[j] * h^2 / 6) for j in 1:n]
  
    s(z, j) = if x[j] ≤ z < x[j+1]
                (M[j] * (x[j+1] - z)^3 / (6 * h)) + (M[j+1] * (z - x[j])^3 / (6 * h)) + C[j] * (z - x[j]) + G[j]
              else
                0
              end
    s(z) = sum(s(z, j) for j in 1:n)
  
    return x, h, s
end

g(x) = cos(2*π*x) * exp(- x^2 / 2)
a, b, n = -2, 2, 9

y = -3:0.01:3
itr = [3; 3:10; 15:5:40; 40]
anim = @animate for i in itr
    x, h, s = equidistant_spline(g, a, b, i)
    M = maximum(D(g, 4).(y)) * h^4 |> x -> round(x; sigdigits=5)
    plot(y, g.(y), xlims=(-3, 3), ylims=(-1, 1.1), 
         label=L"cos(2 \pi x) \cdot e^{- x^2 / 2}",
         legendfontsize=9)
    plot!(y, s.(y), 
          label=L"%$i \; Knoten")
    scatter!(x, s.(x), 
             label=L"error = \mathcal{O} (%$M)")
end
gif(anim, fps=1.5)