using JuMP, Gurobi  # replace GLPK with the name of your solver package if necessary (e.g. Gurobi)
include("./queens_helper.jl")

function queens(n::Int)
    model = Model(Gurobi.Optimizer)

    @variable(model, feld[1:n, 1:n], Bin)

    @constraint(model, rowsum[i=1:n], sum(feld[:, i]) == 1)
    @constraint(model, colsum[i=1:n], sum(feld[i, :]) ≤ 1)
    @constraint(model, diagsum[i=-(n-1):n-1], sum(feld[k, j] for k in 1:n, j in 1:n if k - j == i) ≤ 1)
    @constraint(model, diagsum2[i=2:2*n], sum(feld[k, j] for k in 1:n, j in 1:n if k + j == i) ≤ 1)

    try
        optimize!(model)
    catch err
        println("no solution")
    end

    return value.(feld)
end

# test
Q = queens(21)
print_pattern(Int.(Q))