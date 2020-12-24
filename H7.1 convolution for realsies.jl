using GLMakie, AbstractPlotting, QuadGK, Colors
AbstractPlotting.inline!(true)

function faltung(f::Function, g::Function, x)
    return quadgk(y -> f(x-y)*g(y), -Inf, Inf, rtol=sqrt(eps()))[1]
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

f(x) = abs(x) <= π ? cos(x/2) : 0

xs = -2π:0.1:2π
ϵ = Node(4.)
χs = @lift(χ.($ϵ, $xs))
falts = @lift(faltung.($f, x -> χ($ϵ, x), $xs))


scene, layout = layoutscene(resolution=(1200, 700))
plot = layout[1, 1] = LAxis(scene, title="Faltung")
xlims!(plot, (-2π, 2π)); ylims!(plot, (0, 1))

scene_χ = lines!(plot, xs, χs, color=colorant"indianred1")
scene_f = lines!(plot, xs, f.(xs), color=colorant"deepskyblue")
scene_faltung = lines!(plot, xs, falts, color=colorant"magenta")

legend = LLegend(scene, [scene_χ, scene_f, scene_faltung], ["χ", "f = $f", "Faltung"], halign=:right, valign=:top)
layout[1, 2] = legend


frames = [exp(i) for i in 2:-0.1:-8]
record(scene, "C:\\Users\\april\\Documents\\julia\\approx_durch_faltung.gif", frames, framerate=30) do e
    ϵ[] = e
end