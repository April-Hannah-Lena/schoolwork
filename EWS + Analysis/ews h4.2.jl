using Plots
using PlotThemes
theme(:dark)

p = plot(0:0.1:0.25, x -> 1, leg=false, yscale=:log10)
for n in 2:2:60
    p = plot!(0:0.001:0.25, x -> n * (1-x)^(n-1))
end
display(p)