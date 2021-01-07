using LinearAlgebra, Plots, PlotThemes
using ForwardDiff: gradient, hessian
theme(:dark)

g(x) = (x[1]^2 + x[2] - 11)^2 + (x[1] + x[2]^2 - 7)^2  # Himmelblau function

function gedaempfter_newton(f::Function, x0)
    j, k, x, x_verlauf, h, ĥ = 0, 0, x0, [x0], [1, 1], [0, 0]
    Df(x) = gradient(f, x)
    Hf(x) = hessian(f, x)

    while norm(h) > eps()
        Z = lu(Hf(x))
        h = Z\Df(x)
        x̂ = x - h
        ĥ = Z\Df(x̂)
        while norm(ĥ) > norm(h)
            x̂ = x - 2.0^(-j-k) * h
             ĥ = Z\Df(x̂)
            j += 1
        end
        x = x̂
        j = 0
        k += 1
        push!(x_verlauf, x)
        @show x, norm(Df(x)), norm(h)
    end

    return x, k, x_verlauf
end


x_verläufe = []
x0 = [[-2.0, -2.0], [2.0, -1.0], [0.0, -3.0]]
for i in 1:length(x0)
    x, k, x_verlauf = gedaempfter_newton(g, x0[i])
    append!(x_verläufe, x_verlauf)
    push!(x_verläufe, x, x)
end
for i in 1:10
    x0 = 5 .* rand(2) .- 0.5
    x, k, x_verlauf = gedaempfter_newton(g, x0)
    append!(x_verläufe, x_verlauf)
    push!(x_verläufe, x, x)
end


x_range = [-5:0.1:5, -5:0.1:5]
g_range = [g([x, y]) for x in x_range[1], y in x_range[2]]

anim = @animate for i in 1:length(x_verläufe)
    contour(x_range[1], x_range[2], g_range,
            levels=40, title="Gedämpfter Newton Verfahren für verschiedene x0\n auf die Himmelblau Funktion")
    scatter!((x_verläufe[i][1], x_verläufe[i][2]), leg=false)
end
gif(anim, fps=6)
