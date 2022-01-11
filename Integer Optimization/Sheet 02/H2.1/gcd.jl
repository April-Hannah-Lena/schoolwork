using JuMP
using Gurobi  # replace GLPK with the name of your solver package if necessary (e.g. Gurobi)

function gcd(a::Int, b::Int)
    model = Model(Gurobi.Optimizer)  # replace Gurobi with the name of your solver package if necessary (e.g. Gurobi)
    
    #= 
        TODO for part (a):
        Define your model here. Quick JuMP modelling guide:
        
        VARIABLES
        
        Add a continuous variable x1:
            @variable(model, x1)
        
        Add (continuous) variables x2 and x3 including lower and/or upper bounds:
            @variable(model, x2 >= 0)
            @variable(model, 0 <= x3 <= 1)
        
        Add an integer variable y1:
            @variable(model, y1, Int)
        or
            @variable(model, y1, integer=true)
        
        Add a binary variable y2:
            @variable(model, y2, Bin)
        or
            @variable(model, y2, binary=true)
        or
            @variable(model, 0 <= y2 <= 1, Int)
            
        CONSTRAINTS
        
        Add a constraint:
            @constraint(model, x1 - 2 y1 <= 1)
        or
            @constraint(model, -x1 + 2 y1 >= -1)
        
        Add a constraint named "my_constraint":
            @constraint(model, my_constraint, 2 x1 + y1 - y2 == 2)
        
        OBJECTIVE
        
        Add an objective (does not need to be specified for a feasibility problem):
            @objective(model, Max, 3 x1 + 2 y2)
        or
            @objective(model, Min, -3 x1 - 2 y2)
    =#

    @variable(model, x1, Int)
    @variable(model, x2, Int)
    @constraint(model, a*x1 + b*x2 >= 1)
    @objective(model, Min, a*x1 + b*x2)
    set_optimizer_attribute(model, "OutputFlag", 0)

    # pretty-print the model ...
    print(model)
    
    # ... and solve it
    optimize!(model)
    
    # retrieve and print objective value
    obj_val = round(Int, objective_value(model))
    println()
    println("====== SOLUTION ======")
    println("gcd($(a), $(b)) = ", obj_val)  # Note: everything inside $(...) will be replaced with its actual value
    
    #=
        TODO for part (c):
        Retrieve solution. Access the value that variable x1 takes in the optimal solution by
            value(x1)
    =#
    println(
            "coefficients:  x1 = ", 
            round(Int, value(x1)), 
            ", ($(value(x1)))",
            ",\nx2 = ", 
            round(Int, value(x2)),
            ", ($(value(x2)))"
    )
    println(""); println("")
    return obj_val
end

a = [13, 8265, 918, 2021, 36, 150, -20]
b = [2, 24, 2781, -31, 81, 35, -96]

obj_vals = gcd.(a, b)
println(obj_vals)   
#   [1, 3, 27, 1, 9, 5, 4]

gcd(314159, 2718)
#   ====== SOLUTION ======
#   gcd(314159, 2718) = 1
#   coefficients:  x1 = 0, x2 = 0
#   ???