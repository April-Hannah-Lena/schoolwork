using Plots
using PlotThemes

function h(x, y)
    exp(-(0.1*sqrt(x^2 + y^2)))*sin(sqrt(x^2 + y^2))
end

x = range(-4π, stop=4π, length=30)
y = range(-4π, stop=4π, length=30)
p2 = surface(x, y, h)
theme(:dark)

display(plot(p2))