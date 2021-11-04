using JuMP
using GLPK  # replace GLPK with the name of your solver package if necessary (e.g. Gurobi)

function gcd(a::Int, b::Int)
    model = Model(GLPK.Optimizer)  # replace Gurobi with the name of your solver package if necessary (e.g. Gurobi)
    
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
    
    # pretty-print the model ...
    print(model)
    
    # ... and solve it
    optimize!(model)
    
    # retrieve and print objective value
    println()
    println("====== SOLUTION ======")
    println("gcd($(a), $(b)) = ", round(Int, objective_value(model)))  # Note: everything inside $(...) will be replaced with its actual value
    
    #=
        TODO for part (c):
        Retrieve solution. Access the value that variable x1 takes in the optimal solution by
            value(x1)
    =#
end