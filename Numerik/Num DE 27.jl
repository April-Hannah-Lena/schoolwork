using DifferentialEquations, BoundaryValueDiffEq

function thomas_fermi!(du, u, p, t)
    du[1] = t * u[2]
    du[2] = 4 * u[1]^1.5
end

function bc!(residual, u, p, t)
    residual[1] = u[1][1] - 1
    residual[2] = u[1][end]
end

tspan = (0., 5.)
u₀_guess = [1., 1.]

bvp = BVProblem(thomas_fermi!, bc!, u₀_guess, tspan)
sol = solve(bvp, Shooting(RK4()))
# instability detected ???

using ODEInterface
