using TSPLIB
using Graphs, GraphPlot, GraphsFlows
using LinearAlgebra, Colors, Cairo

#= Returns the (undirected) graph underlying a given TSP instance from TSPLIB. =#
function get_graph(tsp::TSP)
    tsp_graph = Graph(tsp.dimension)
    for i in 1:tsp.dimension, j in 1:i-1
        add_edge!(tsp_graph, i,j)
    end
    return tsp_graph
end

#= Plots the graph underlying a given TSP instance with given node coordinates (if present),
   or else in an automatic graph layout. =#
function plot_tsp(tsp::TSP; solution=[])
    tsp_graph = get_graph(tsp)

    # sort edge tuples if necessary
    solution = [i < j ? (i,j) : (j,i) for (i,j) in solution]

    edge_colour = (length(solution) == 0) ? RGBA(0.749,0.749,0.749,0.4) : RGBA(0,0,0,0)
    kwargs = Dict(
        :nodefillc => "grey75",
        :edgestrokec => [(src(e),dst(e)) in solution ? "orange" : edge_colour
                         for e in edges(tsp_graph)],  # colour all edges in tour in orange
        :nodelabel => vertices(tsp_graph), :nodesize => 2
    )

    # check whether the given instance has coordinates
    if norm(tsp.nodes) > 0
        gplot(tsp_graph, tsp.nodes[:,1], tsp.nodes[:,2]; kwargs...)
    else
        gplot(tsp_graph; kwargs...)
    end
end


#= Helper function #1 for subtour elimination: 
   Takes a TSP instance and integral solution values for the edge variables x and
   finds a subtour (cycle) in the subgraph induces by the edges that take value 1.
   Returns a tuple (S, notS) consisting of the set vertices in the subtour and its complement,
   or (0,0) if no subtour exists. =#
function find_subtour(tsp::TSP, x_values)
    # build an undirected graph that only contains solution edges
    tsp_graph_tmp = Graph(tsp.dimension)
    for i in 1:nv(tsp_graph_tmp), j in i+1:nv(tsp_graph_tmp)
        if x_values[i,j] > 0.9  # account for small deviations from integrality
            add_edge!(tsp_graph_tmp, i,j)
        end
    end

    # find connected components = cycles of the subgraph induces by the solution
    cycles = connected_components(tsp_graph_tmp) 
    if length(cycles) > 1  # subtour exists
        S = Set(cycles[1])  # take the first subtour
        notS = setdiff(vertices(tsp_graph_tmp), S)    
        return (S, notS)
    else
        return (0,0)
    end
    return (0,0)  # no cut with value < 2 has been found
end

#= Helper function #2 for subtour elimination:
   Takes a TSP instance and edge weights in [0,1] and finds the shores
   of a minimum cut of weight less than 2, if one exists. Otherwise,
   the return value is (0,0). =#
function find_minimum_cut_partition(tsp::TSP, x_values)
    g_flow = DiGraph(tsp.dimension)
    for i in 1:tsp.dimension, j in i+1:tsp.dimension
        add_edge!(g_flow, i,j)
    end

    # compute min 1-t-cut for all vertices t different from 1
    for t in 2:tsp.dimension
        S, notS, cut_value = GraphsFlows.mincut(g_flow, 1, t, x_values, DinicAlgorithm() )
        if cut_value < 2
            return (S, notS)
        end
    end
    return (0,0)  # no cut with value < 2 has been found
end
