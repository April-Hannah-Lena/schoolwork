using DifferentialEquations, OrdinaryDiffEq, LinearAlgebra

N = 100
A = SymTridiagonal(-2 .* ones(N), ones(N-1))

tspan = (0.0, 10.0)
dt = 1
u0 = sin.(range(0, pi, length=p[1]))
trusol = [exp(t * A) * u0 for t in tspan[1]:dt:tspan[2]]

prob = ODEProblem(f!, u0, tspan)
err = []

for alg in [Euler(), ImplicitEuler(), DP5(), Trapezoid(), ImplicitMidpoint(), RK4(), RadauIIA5()]

    prob = ODEProblem(f!, u0, tspan)
    sol = solve(prob, alg; adaptive=false, dt=dt)

    push!(err, 
        maximum( norm(trusol[i] - (sol.u)[i]) for i in 1:length(trusol) )
    )
end
