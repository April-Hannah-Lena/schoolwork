using GLMakie, AbstractPlotting, QuadGK, Colors
AbstractPlotting.inline!(false)

function faltung(f::Function, g::Function, x)
    return quadgk(y -> f(x-y)*g(y), -Inf, Inf, rtol=sqrt(eps()))[1]
end
function modified_faltung(f::Function, g::Function, x, shift)
    f(x) == 0 || g(x - shift) == 0 ? 0.0 : faltung(f, g, x)
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

f(x) = abs(x) <= π ? x * cos(x/2) + 0.5 * cos(5x/2) : 0


x_range = -5π/4:0.1:5π/4    #χ_range = @lift(χ.($ϵ, $x_range))
#faltung_range = @lift(faltung.($f, x -> χ($ϵ, x), $x_range))

scene, layout = layoutscene(resolution = (1500, 1000))   #backgroundcolor=colorant"#323a43"
plot1 = layout[2, 1] = LAxis(scene)
plot2 = layout[3, 1] = LAxis(scene)
supertitle = layout[1, :] = LText(scene, "Wenn ϵ sich der 0 nähert, nähert sich das\n Faltungsintegral der Funktionsauswertung an der Stelle x", tellwidth = false)


x_slider = layout[4, 1] = LSlider(scene, range = -2π:0.1:2π, startvalue = 0.5)
x_value = lift(x_slider.value) do x
            s = string(x, "00000")
            s[1:5]
          end
x_label = layout[5, 1] = LText(scene, "x ∈ (-2π, 2π)", tellwidth = false)

ϵ_slider = layout[3, 2] = LSlider(scene, range = [exp(i) for i in 2:-0.01:-3.7], startvalue = 1.0, horizontal = false)
ϵ_value = lift(ϵ_slider.value) do x
            s = string(x, "00000")
            s[1:5]
          end
ϵ_label = layout[3, 3] = LText(scene, "ϵ ∈ (0.02, 7)\n logarithmisch skaliert", rotation = 3π/2, tellheight = false)

χ_range = @lift(χ.($(ϵ_slider.value), x_range .- $(x_slider.value)))
χ_full = @lift(χ.($(ϵ_slider.value), x_range))
faltung_range = @lift(modified_faltung.(f, z -> χ($(ϵ_slider.value), z), x_range, $(x_slider.value)))
faltung_full = @lift(faltung.(f, z -> χ($(ϵ_slider.value), z), x_range))


plot_f_full = lines!(plot1, x_range, f.(x_range), color=colorant"indianred1")
plot_χ_full = lines!(plot1, x_range, χ_full, color=colorant"deepskyblue")
plot_faltung_full = lines!(plot1, x_range, faltung_full, color=colorant"magenta")

plot_f = lines!(plot2, x_range, f.(x_range), color=colorant"indianred1")
plot_χ = lines!(plot2, x_range, χ_range, color=colorant"deepskyblue")
plot_faltung = lines!(plot2, x_range, faltung_range, color=colorant"magenta")


#leg_x = [MarkerElement(color = :black, marker = "x", strokecolor = :black)]
#leg_ϵ = [MarkerElement(color = :black, marker = "ϵ", strokecolor = :black)]
legend = LLegend(scene, [plot_χ, plot_f, plot_faltung], 
                        ["Friedrichglättungskern χ", "f = x cos(x/2) + cos(5x/2) / 2", "Faltung"], 
                 halign=:right, valign=:bottom, margin=(10, 10, 10, 10), 
                 tellheight = false, tellwidth = true)
layout[2, 1:3] = legend


scene


#save("C:\\Users\\april\\Documents\\julia\\plot.jpg", plot)
#frames = [exp(i) for i in 2:-0.1:-8]
#record(plot, "C:\\Users\\april\\Documents\\julia\\χ_ϵ.gif", frames, framerate=30) do e
#    ϵ[] = e
#end

#scene = Scene(backgroundcolor = colorant"#323a43")
#set_theme!(backgroundcolor = :gray)

#axis = scene[Axis]
#axis.grid
#axis.grid.linecolor = ((colorant"#6f8095", 0.3), (colorant"#6f8095", 0.3))
#scene
