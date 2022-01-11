using JuMP, Gurobi

#= input data =#
n = 10
c = [2, 3, 4, 4, 5, 1, 7, 9, 2, 1]
p = [0.4, 0.3, 0.7, 0.5, 0.9, 0.2, 0.3, 0.1, 0.2, 0.5]

model = Model(Gurobi.Optimizer)
@variable(model, x[1:n], Bin)
@variable(model, f[1:n+1])

@constraint(model, f[1] == c'x)
@constraint(model, ff[i=1:n], f[i+1] ≤ (1-x[i]) * f[i] + x[i] * p[i] * f[i])

@objective(model, Max, f[n+1])
optimize!(model)

obj = objective_value(model)
target_items = findall(isone, value.(x))

println("\nSteal items ", target_items)
println("Maximum expected reward = $(obj)")