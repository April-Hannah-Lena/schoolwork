using Plots
f = sin
p1 = plot(f, z -> f(2z), 0, 2π)
theme(:dark)

function h(x, y)
    exp(-(x^2 + y^2))*sin(sqrt(x^2 + y^2))
end
x = range(-π, stop=π, length=10)
y = range(-π, stop=π, length=10)
p2 = surface(x, y, h)

display(plot(p1, p2, layout=2))