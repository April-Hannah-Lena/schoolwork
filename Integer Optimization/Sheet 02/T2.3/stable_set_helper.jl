using Graphs, GraphPlot
using Gadfly

function plot_graph(graph::Graph; coordinates=nothing, solution=nothing)
    palette1 = ["grey65", "orange", "orange"]
    palette2 = ["grey65", "grey65", "orange"]
    color_indices = isnothing(solution) ? repeat([1], nv(graph)) : round.(Int, solution * 2) .+ 1
    
    kwargs = Dict(
        :nodefillc => palette2[color_indices], :nodestrokec => palette1[color_indices], 
        :nodestrokelw => 4, :nodesize => 8,
        :edgestrokec => "grey75", :edgelinewidth => 1.5,
        :nodelabel => solution, :nodelabeldist => 2.5, :nodelabelangleoffset => -π/4,
        :nodelabelsize => 4
    )
    
    if !isnothing(coordinates)
        x, y = coordinates[:,1], coordinates[:,2]
        display(gplot(graph, x, -y; kwargs...))
    else
        display(gplot(graph; kwargs...))
    end
end