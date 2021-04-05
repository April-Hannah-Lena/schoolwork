using Plots, PlotThemes, ForwardDiff, LaTeXStrings
theme(:dark)

nzero(x) = filter(x -> x != 0, x)
function spline(f, n)
    X = @. cos((0:n) * π/n)
    ω(x) = x .- X |> nzero |> prod
    λ = @. 1.0 / ω(X)
    p(x, k) = if k-1 ≤ x < k + 1
                sum(@. λ * f(X + k) / (x - (X + k))) / sum(@. λ / (x - (X + k)))
              else
                0
              end
    p(x) = sum(p(x, k) for k in -n:2:n)
    return X, p
end

f(x) = cos(2*π*x) * exp(- x^2 / 2)
y = -3:0.01:3
itr = vcat(1:1:8, 10:2:20, 22:10:52)
anim = @animate for i in itr
    X, p = spline(f, i)
    plot(y, f.(y), xlims=(-3, 3), ylims=(-1, 1.1), 
          label=L"cos(x) \cdot e^{- x^2 / 2}",
          legendfontsize=9)
    plot!(y, p.(y), 
          label=L"%$i . Spline")
    scatter!(X, f.(X), 
          label=L"error = \mathcal{O} (c^{%$i})")
end
gif(anim, fps=3)