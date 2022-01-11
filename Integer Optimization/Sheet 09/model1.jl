using JuMP

model = Model(Gurobi.Optimizer)
@variable(model, x[1:2])
@constraint(model, 3*x[1] + 4*x[2] >= 8)
@constraint(model, x[2] - x[1] <= 2)
@constraint(model, 4*x[1] + 6*x[2] <= 27)
@constraint(model, 4*x[1] - 10*x[2] <= 3)
@objective(model, Max, x[2])