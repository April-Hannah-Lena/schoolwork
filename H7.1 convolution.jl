using QuadGK, Plots, PlotThemes
theme(:dark)

function faltung(f::Function, g::Function, x)
    return quadgk(y -> f(x-y)*g(y), -Inf, 0, Inf, rtol=sqrt(eps()))[1]
end

function χ_gen(x)
    if abs(x) <= 1
        1
    elseif 1 < abs(x) <= 2
        2 - abs(x)
    else
        0
    end
end
norm, err = quadgk(χ_gen, -2, 2)
χ(ϵ, x) = χ_gen(x / ϵ) / (ϵ * norm)

f(x) = abs(x) <= π ? x * cos(x/2) + 0.5cos(5x/2) : 0
plot(xs, f.(xs))

xs = -2π:0.1:2π
frames = [exp(i) for i in 2:-0.05:-5]
anim2 = @animate for j in frames
    ϵ = floor(j, digits=4)
    plot(xs, f.(xs), xlims=(-3π/2, 3π/2), ylims=(-π/2, π/2), title="ϵ = $ϵ", label="f", legend=:bottomright)
    plot!(xs, χ.(j, xs), label="χ")
    plot!(xs, faltung.(f, x -> χ(j, x), xs), label="faltung")
end
gif(anim2, fps=30)

xs2 = -2:0.1:2
f1(x) = 0 <= x <= 1 ? 1 : 0
f2(x) = 0 <= x <= 1 ? 2x : 0
plot(xs2, faltung.(f2, f1, xs2))
plot!(xs2, faltung.(f2, f1, xs2).^2)