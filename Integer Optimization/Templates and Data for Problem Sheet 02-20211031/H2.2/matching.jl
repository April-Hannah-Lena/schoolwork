using JuMP, GLPK  # replace GLPK with the name of your solver package if necessary (e.g. Gurobi)
using DelimitedFiles, Graphs
include("matching_helper.jl")

function max_matching(graph::Graph)
    #=
        TOOD: 
        Find a maximum matching in the input graph and 
        return your solution as a list of tuples (i,j) 
        where i and j are vertices.
        
        JuMP modelling guide (continued):
        
        VARIABLES
        
        Add a vector of 10 integer variables z[1] to z[10] that can each take values -1,0,1:
            @variable(model, -1 <= z[1:10] <= 1, Int)
            
        Add a 10 x 5 two-dimensional array of binary variables v:
            @variable(model, v[1:10,1:5], Bin)
            
        Add a vector of integer variables w indexed by the elements of some list:
            index_list = ["a", "b", "c"]
            @variable(model, w[index_list], Int)
        Another possible example could be
            index_list = [(1,1),(2,2),(3,3)]
        
        CONSTRAINTS
        
        Add a group of constraints, one for every i from 1 to 9 
        (my_constraints[i] references the i-th constraint):
            @constraint(model, my_constraints[i=1:9], z[i+1] - z[i] <= 1)
        This is (up to constraint names) equivalent with:
            @constraint(model, z[2] - z[1] <= 1)
            @constraint(model, z[3] - z[2] <= 1)
        and so on ...
        
        OBJECTIVE
        
        Minimize the sum of the z's:
            @objective(model, Min, sum(z))
        or
            @objective(model, Min, sum(z[1:10]))
        or
            @objective(model, Min, sum(z[i] for i=1:10))
            
        Maximize the sum of the first two rows of v:
            @objective(model, Max, sum(v[1:2,:]))
        or
            @objective(model, Max, sum(v[i,j] for i=1:10, j=1:5 if i <= 2))
    =#
    
    return []  #= TODO: Replace with correct return value.
        For a vector of variables z,
            value.(z)
        returns the values (as a vector again) that the variables z take in the optimal solution.
    =#
end


# read adjacency matrix ...
adj_matrix = readdlm("adj-4.txt", Bool)  # select test instance by replacing filename here

# ... and construct graph from it
graph = Graph(adj_matrix)

# count vertices and edges
n = nv(graph)
m = ne(graph)
println("constructed a graph with $(n) vertices and $(m) edges")  # Note: everything inside $(...) will be replaced with its actual value

# iterate over the vertices and their neighbors ...
for v in vertices(graph)
    println("vertex $(v) has neighbors ", neighbors(graph, v))
end
# ... and over the edges
for e in edges(graph)
    i, j = src(e), dst(e)
    println("edge between $(i) and $(j)")
end


# find a maximum matching
matching = max_matching(graph)

# plot graph (and solution)
plot_bip_graph(graph, solution=matching)