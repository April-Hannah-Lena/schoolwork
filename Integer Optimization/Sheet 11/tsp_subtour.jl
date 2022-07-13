using JuMP, Gurobi
using TSPLIB
include("tsp_helper.jl")

#= Subtour elimination approach =#
function solve_tsp_subtour(tsp::TSP; integer_only=true)
    # get undirected graph underlying the TSP instance
    tsp_graph = get_graph(tsp)
    
    model = Model(Gurobi.Optimizer)
    
    #=
        TODO: 
        Define variables and constraints here.
    =#

    # subtour elimination callback
    function subtour_callback(cb_data)
        status = callback_node_status(cb_data, model)
        if status == MOI.CALLBACK_NODE_STATUS_INTEGER || MOI.CALLBACK_NODE_STATUS_FRACTIONAL
            x_values = callback_value.(Ref(cb_data), x)
            
            if status == MOI.CALLBACK_NODE_STATUS_INTEGER
                # integral solution
                S, notS = find_subtour(tsp, x_values)
            elseif status == MOI.CALLBACK_NODE_STATUS_FRACTIONAL && !integer_only
                # fractional solution
                S, notS = find_minimum_cut_partition(tsp, x_values)
            end

            if S != 0
                subtour_constraint = @build_constraint(
                    # TODO for part b: define subtour elimination constraint here
                )
                MOI.submit(model, MOI.LazyConstraint(cb_data), subtour_constraint)
                println("Adding subtour elimination constraint for $S")
            else
                println("No suitable cut found")
            end
        end
    end

    # activate callback function
    MOI.set(model, MOI.LazyConstraintCallback(), subtour_callback)
    
    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL  # if model was solved to optimality
        # compare optimal objective value with TSPLIB benchmark
        println("Optimal solution with objective value $(objective_value(model)) found (should be $(tsp.optimal)).")
        tsp_solution = []  # TODO: replace with correct return value
    else  # no solution
        println(raw_status(model))
        tsp_solution = []
    end
    return tsp_solution
end