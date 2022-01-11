using JuMP, Gurobi
using DelimitedFiles, LinearAlgebra
include("./facility_location_helper.jl")

# read input data
customers, _ = readdlm("customers.csv", ';', header=true)
locations, _ = readdlm("locations.csv", ';', header=true)

k = size(locations, 1)
m = size(customers, 1)
println("$(k) potential hub locations and $(m) customers")

# locations: k x 3 matrix
# customers: m x 3 matrix
# let's take a look at some of the input (same format for both locations and customers):
for i=1:k
    name = locations[i,1]
    x,y = locations[i,2:3]  # x = longitude, y = latitude
    println("Location $(i): $(name) at coordinates ($(x), $(y))")
end


#=
    TODO: 
    Solve the instance of the facility location problem.
    Convert your solution into a dictionary that maps a location i to 
    a list of those customer indices served from i.
   
    Examplary dictionary constructor:
        Dict(i => [] for i=1:k)
    maps every location to an empty list.
=#

M = 20
C = 10 * rand(k)
C = repeat(C, 1, m)
#C = repeat([0], k, m)
dists = [norm(locations[i, 2:3] - customers[j, 2:3]) for i in 1:k, j in 1:m]

model = Model(Gurobi.Optimizer)
@variable(model, x[1:k, 1:m], Bin)

@constraint(model, per_customer[i=1:m], sum(x[:, i]) == 1)
@constraint(model, per_facility[j=1:k], sum(x[j, :]) ≤ M)
@objective(model, Min, sum(x .* (C + dists)))

optimize!(model)
x = Bool.(value.(x))

assignment = Dict(i => findall(isone, x[i, :]) for i in 1:k)  # TODO: replace with correct solution dictionary
plot_solution(locations, customers, assignment)
