using Plots
using PlotThemes
theme(:dark)

X1 = 
X2 = [0, 1]

function Y1(x1, x2)
    return sqrt(-2 * log10(x1)) * cos(2π * x2)
end
function Y2(x1, x2)
    return sqrt(-2 * log10(x1)) * sin(2π * x2)
end

p1 = surface(X1, X2, Y1)
p2 = surface!(X1, X2, Y2)
display(plot(p2))