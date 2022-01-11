using JuMP

k = 3
model = Model(Gurobi.Optimizer)
@variable(model, x[1:2])
@constraint(model, x[1] + 2k*x[2] <= 2k)
@constraint(model, x[1] - 2k*x[2] <= 0)
@constraint(model, x[1] >= 0)
@objective(model, Max, x[1])