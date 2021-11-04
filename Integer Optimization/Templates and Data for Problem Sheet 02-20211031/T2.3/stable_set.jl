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
    return nothing  # TODO: replace with correct return value
end

# read test instance (adjacency matrix + vertex coordinates for visualization)
adj_matrix = readdlm("bayg29_adjacency.txt", Bool)
coords = readdlm("bayg29_coordinates.txt", '\t', Int)[:,2:3]  # ignore first column

# construct graph from adjacency matrix
graph = Graph(adj_matrix)

# compute a maximum stable set
stab = max_stable_set(graph)

# plot graph and optimal solution
plot_graph(graph, coordinates=coords, solution=stab)