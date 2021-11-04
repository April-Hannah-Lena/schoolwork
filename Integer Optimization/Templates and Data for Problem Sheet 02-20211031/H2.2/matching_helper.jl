using Graphs, GraphPlot
using Gadfly

#= returns the greatest vertex (with maximum index) such that all smaller vertices 
   form a stable set (guessing the bipartition) =#
function find_bipartition(graph::Graph)
    k = nv(graph)
    i = 1
    while i < k
        neighbs = [j for j=i+1:k if has_edge(graph, i,j)]
        k = isempty(neighbs) ? k : minimum(neighbs)
        i += 1
    end
    return k-1
end


# solution: list of tuples (i,j) where i and j are vertices
function plot_bip_graph(graph::Graph; solution=[])
    # sort edge tuples if necessary
    solution = [i < j ? (i,j) : (j,i) for (i,j) in solution]
    
    # assuming a bipartite graph with vertex classes 1:n and (n+1):nv(graph)
    n = find_bipartition(graph)
    x = vcat(repeat([0], n), repeat([1], nv(graph)-n))
    y = vcat(1:n, 1:nv(graph)-n)
    
    display(gplot(graph, x, y, 
        nodefillc="grey75",
        edgestrokec=[(src(e),dst(e)) in solution ? "orange" : "grey75" for e in edges(graph)],
        nodelabel=1:nv(graph)
    ))
end