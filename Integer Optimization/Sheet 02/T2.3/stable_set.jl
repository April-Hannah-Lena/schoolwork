using JuMP, GLPK  # replace GLPK with the name of your solver package if necessary (e.g. Gurobi)
using DelimitedFiles, Graphs
include("./stable_set_helper.jl")

function max_stable_set(graph::Graph)
    #=
        TODO:
        Find a maximum stable set in the input graph and
        return a vector whose $i$th entry equals 1 
        if vertex i is contained in the solution and 0 otherwise.
    =#

    Adj = adjacency_matrix(graph)
    #n = size(Adj)[1]
    E = collect(edges(graph))
    E = hcat([src(e) for e in E], [dst(e) for e in E])
    #strain = [(i, j) for i in 1:n, j in 1:n if Adj[i, j] ≈ 1 && i ≤ j]

    model = Model(Gurobi.Optimizer)
    @variable(model, x[vertices(graph)], Bin)
    @constraint(model, stable[i=1:size(E, 1)], x[E[i, 1]] + x[E[i, 2]] ≤ 1)
    @objective(model, Max, sum(x))

    optimize!(model)

    return value.(x)  # TODO: replace with correct return value
end

# read test instance (adjacency matrix + vertex coordinates for visualization)
cd("C:\\Users\\april\\Documents\\schoolwork\\Integer Optimization\\Templates and Data for Problem Sheet 02-20211031\\T2.3")
adj_matrix = readdlm("bayg29_adjacency.txt", Bool)
coords = readdlm("bayg29_coordinates.txt", '\t', Int)[:,2:3]  # ignore first column

# construct graph from adjacency matrix
graph = Graph(adj_matrix)

# compute a maximum stable set
stab = max_stable_set(graph)

# plot graph and optimal solution
plot_graph(graph, coordinates=coords, solution=stab)