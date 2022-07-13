using JuMP, Gurobi
using TSPLIB
using Random
Random.seed!(1234)
include("tsp_helper.jl")

#= 
    Blueprint for TSP solver function: 
    Takes a TSP instance from the TSPLIB collection,
    solves it, and returns the optimal tour as a list of tuples (i,j) where i and j are vertices.
    If the instance has no solution, the return value is the empty list [].
=#
function solve_tsp_xxx(tsp::TSP)
    # get undirected graph underlying the TSP instance
    tsp_graph = get_graph(tsp)
    n = tsp.dimension
    v₀ = rand(1:n)

    model = Model(Gurobi.Optimizer)

    @variable(model, x[1:n,1:n], Bin)
    @constraint(model, deg_in[i=1:n], sum(x[i, j] for j in 1:n if i != j) == 1)
    @constraint(model, deg_out[i=1:n], sum(x[j, i] for j in 1:n if i != j) == 1)

    @variable(model, y[1:n], Int)
    @constraint(model, y[v₀] == 1)
    
    for i in 1:n, j in 1:n
        if i != v₀ 
            @constraint(model, 2 ≤ y[i] ≤ n)
            if j != v₀ && i != j
                @constraint(model, y[i] - y[j] + (n-1) * x[i, j] ≤ n - 2)
            end
        end
    end
    
    w = tsp.weights
    for i in 1:n
        w[i, i] = zero(eltype(w))
    end
    @objective(model, Min, sum(w .* x))

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL  # if model was solved to optimality
        # compare optimal objective value with TSPLIB benchmark
        println("Optimal solution with objective value $(objective_value(model)) found (should be $(tsp.optimal)).")
        
        tsp_solution = []
        x̄, ȳ = value.(x), value.(y)
        ord = sortperm(ȳ)
        for i in ord
            push!(tsp_solution, (i, findfirst(!iszero, x̄[i, :])) )
        end
    else  # no solution
        println(raw_status(model))
        tsp_solution = []
    end
    return tsp_solution
end