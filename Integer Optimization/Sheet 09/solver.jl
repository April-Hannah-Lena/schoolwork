using JuMP, Gurobi
include("./solver_helper.jl")

# load model file
MODEL_PATH = "./model2.jl"  # modify file path here to load a different model
include(MODEL_PATH)
set_silent(model)  # suppress solver output if desired

print(model)
println()

# initialize drawing canvas for visualization
canvas = Canvas2D(model)

IT = 40  # maximum number of iterations

anim = @animate for it=1:IT
    # solve the current model and retrieve optimal solution
    optimize!(model)
    x_star = value.(x)
    
    # plot current model
    plot_model_2d(model, canvas; init=(it==1), index=it)

    # check whether current optimal solution is integral
    if all(isinteger, x_star)  # TODO: replace with correct condition
        println("Done. Optimal integer solution: ", x_star)
        break  # exit loop
    end
    
    # compute a CG cut and add it to the model.
    A, b = get_active_constraints(model)

    i = findfirst(!isinteger, x_star)
    y = vcat(fill(0., i-1), [1.], fill(0., length(x_star)-i))

    y = A' \ y
    
    while !all(y .> 0.)
        y .+= 1.
    end

    i = round(Int, b'y, RoundDown)
    y = A'y

    @constraint(model, y'x <= i)

end

# create animated plot and save to file
gif(anim, splitext(MODEL_PATH)[1] * ".gif", fps=1)