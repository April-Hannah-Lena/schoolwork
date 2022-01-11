using JuMP
using Plots

Base.round(::Type{Int}, n::Int, ::RoundingMode) = n
#= Returns a subsystem of those constraints that are active in the current optimal solution.
   Only to be called after optimize!(model). Return value is a tuple (A, b)
   where A is a matrix and b a (column) vector. =#
function get_active_constraints(model::Model)
    active_constraints = [
        row for (f_type, s_type) in list_of_constraint_types(model) 
            for row in all_constraints(model, f_type, s_type)
        if isapprox(value(row), normalized_rhs(row))
    ]
    
    A = [round.(Int, normalized_coefficient.(row, all_variables(model))) for row in active_constraints]
    b = normalized_rhs.(active_constraints)  # int conversion?
    return hcat(A...)', b
end


#= Represents a canvas object created from 2-dimensional model. =#
struct Canvas2D
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
    
    offset::Float64
    
    function Canvas2D(model::Model)
        if length(all_variables(model)) != 2
            error("Incompatible problem dimension")
        end
        
        bounds = get_canvas_bounds(model)
        xmin, xmax = bounds[all_variables(model)[1]]
        ymin, ymax = bounds[all_variables(model)[2]]
        
        return new(xmin, xmax, ymin, ymax, 0.25)
    end
    
    # calculate bounds for drawing canvas
    function get_canvas_bounds(model::Model)    
        # store original objective and optimizer setting
        obj = objective_function(model)
        is_silent = get_optimizer_attribute(model, MOI.Silent())
        set_silent(model)
        
        bounds = Dict{VariableRef, Tuple{Float64, Float64}}()
        
        # optimize in +/- coordinate directions
        for var in all_variables(model)
            # upper bound
            set_objective_function(model, var)
            optimize!(model)
            
            if has_values(model)
                ub = objective_value(model)
            else
                error("Feasible region unbounded in direction ", var)
                ub = 0
            end
            
            # lower bound
            set_objective_function(model, -var)
            optimize!(model)
            
            if has_values(model)
                lb = -objective_value(model)
            else
                error("Feasible region unbounded in direction -", var)
                lb = 0
            end
            
            bounds[var] = (lb, ub)
        end
        
        # reset objective
        set_objective_function(model, obj)
        if !is_silent
            unset_silent(model)
        end
        
        return bounds
    end
end


#= Plots hyperplanes (= lines in 2 dimensions) corresponding to the model constraints
   onto an existing canvas. =#
function plot_model_2d(model::Model, canvas::Canvas2D; init=false, index=-1)
    xmin, xmax, ymin, ymax = canvas.xmin, canvas.xmax, canvas.ymin, canvas.ymax
    DELTA = canvas.offset
    
    if init
        # clear plot pane
        plot(
            xlims=(xmin-.5,xmax+.5), ylims=(ymin-.5,ymax+.5),
            xticks=floor(xmin):1:ceil(xmax), yticks=floor(ymin):1:ceil(ymax),
            legend=false, aspect_ratio=:equal,
            xlabel="x1", ylabel="x2"
        )
    end
    
    for (f_type, s_type) in list_of_constraint_types(model)
        for con in all_constraints(model, f_type, s_type)
            lhs = normalized_coefficient.(con, all_variables(model))
            rhs = normalized_rhs(con)
            
            # compute all intersections with bounding box
            
            if isapprox(lhs[1], 0)  
                # (assuming that second coefficient lhs[2] is nonzero!)
                xs_on_bound = [xmin-DELTA, xmax+DELTA]
                ys_on_bound = [rhs / lhs[2], rhs / lhs[2]]
            elseif isapprox(lhs[2], 0)
                ys_on_bound = [ymin-DELTA, ymax+DELTA]
                xs_on_bound = [rhs / lhs[1], rhs / lhs[1]]
            else
                xs_on_bound = [
                    xmin-DELTA, 
                    xmax+DELTA,
                    (rhs - lhs[2] * (ymin-DELTA)) / lhs[1],
                    (rhs - lhs[2] * (ymax+DELTA)) / lhs[1]
                ]
                ys_on_bound = [
                    (rhs - lhs[1] * (xmin-DELTA)) / lhs[2],
                    (rhs - lhs[1] * (xmax+DELTA)) / lhs[2],
                    ymin-DELTA,
                    ymax+DELTA
                ]
            end

            plot!(
                xs_on_bound, ys_on_bound, 
                lc=init ? :blue3 : :purple3, lw=init ? 2.5 : 1,
                title=index > 0 ? "Iteration $(index)" : ""
            )
        end
    end
    
    return current()
end