using Plots
using PlotThemes
theme(:dark)

function fn(N, X)
    (N / X * sin(X / N))^2
end

r = [0.0]
for i in range(0.0, stop=π, length=50)
    push!(r, i^2)
end

@gif for n in r
    plot(x -> fn(n, x), xlims=(-π, π), ylims=(0, 1))
end
