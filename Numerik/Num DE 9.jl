using Plots, LinearAlgebra, PlotThemes
theme(:dark)

function RungeKutta4(f, t, x, h)
    b = [1/6, 1/3, 1/3, 1/6]

    k = [f(t, x)]
    k = push!(k, f(t + 0.5*h, x + h*0.5*k[1]))
    k = push!(k, f(t + 0.5*h, x + h*0.5*k[2]))
    k = push!(k, f(t + h, x + h*k[3]))

    return t + h, x .+ h .* sum(b .* k)
end

function f(t, x; a = ones(4))
    b = a[1]*x[1] - a[2]*x[1]*x[2]
    r = -a[3]*x[2] + a[4]*x[1]*x[2]
    return [b, r]
end

H(x,y) = x - log(x) + y - log(y)
x = 0.1:0.1:4; y = x
contour(x, y, H.(x,y'))

x0 = [1.0, 1.5]
tspan = [0.0, 50.0]
h = 0.5
x, t = x0, tspan[1]
sol = [x0]
while t ≤ tspan[2]
    t, x = RungeKutta4(f, t, x, h)
    push!(sol, x)
end

plot(getindex.(sol, 1), getindex.(sol, 2))
plot(H.(getindex.(reverse(sol), 1), getindex.(reverse(sol), 2)))
anim = @animate for i in 1:102
    plot(getindex.(sol[1:i], 1), getindex.(sol[1:i], 2))
    #plot(getindex.((sol.u)[1:i], 1), getindex.((sol.u)[1:i], 2))
end
gif(anim)


using DifferentialEquations
# ODE
function räuber_beute!(dx, x, p, t)
    dx[1] = x[1] - x[1].*x[2]
    dx[2] = -x[2] + x[1].*x[2]
end
   
# solution by different integrators
x0 = [1.0, 1.5]
tspan = (0.0, 50.0)
prob = ODEProblem(räuber_beute!, x0, tspan)
h = 0.5
scheme = Euler() # or ImplicitEurler() or Midpoint()
sol = solve(prob, scheme, dt=h, adaptive=false)
plot(sol, vars=(1,2), marker=:dot, plotdensity=500)
plot(H.(getindex.(sol.u, 1), getindex.(sol.u, 2)))