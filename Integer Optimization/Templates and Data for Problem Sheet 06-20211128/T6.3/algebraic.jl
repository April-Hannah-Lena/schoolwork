using JuMP, Gurobi

function find_coefficients(x, d, A; epsilon=1e-6)

    xx = x .^ range(0, d, step=1)
    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model, "OutputFlag", 0)
    @variable(model, a[1:d+1, 1:3], Int)

    # abs
    @constraint(model, 0 .≤ a[:, 2:3] .≤ 1)
    @constraint(model, posabs[i=1:d+1], a[i, 1] * a[i, 2] - a[i, 1] * a[i, 3] ≥ a[i, 1])
    @constraint(model, negabs[i=1:d+1], a[i, 1] * a[i, 2] - a[i, 1] * a[i, 3] ≥ -a[i, 1])
    @constraint(model, sum(a[i, 1] * a[i, 2] - a[i, 1] * a[i, 3] for i in 1:d+1) ≥ 1)

    @constraint(model, -A .≤ a[:, 1] .≤ A)
    @constraint(model, -epsilon ≤ (a[:, 1])'xx ≤ epsilon)
    @objective(model, Min, (a[:, 1])'xx)
    #@objective(model, Min, (a[:, 1])'ones(d+1))

    optimize!(model)
    xx = try round.(Int, value.(a[:, 1]))
    catch err
        @error "No integer polynomials of degree $d with coeffs in -$A : $A"
    end
    return xx
end


examples = [
    1.7320508, 
    1.6180339, 
    3.1415926, 
    1.3415037, 
    3.1462643
]

find_coefficients(examples[3], 6, 10, epsilon=1e-7)