using Plots

function plot_solution(locations, customers, assignment=nothing)
    # plot hub locations
    plot(
        float.(transpose(locations[:,2])), float.(transpose(locations[:,3])),
        linetype=:scatter, markersize=12, palette=palette(:tab20), markerstrokewidth=0, markerstrokecolor="white",
        ticks=nothing, border=:none, size=(800,1000), legend=false
    )

    # plot customers in colour-coded clusters, one for each hub location
    kwargs = Dict(
        :linetype=>scatter, 
        :markerstrokewidth=>0, :markerstrokecolor=>"white",
        :markersize=>5,
        :alpha=>0.8
    )
    
    if isnothing(assignment)
        plot!(customers[:,2], customers[:,3], color="grey75"; kwargs...)
    else
        for i=1:size(locations, 1)
            plot!(customers[assignment[i],2], customers[assignment[i],3], color=palette(:tab20)[i]; kwargs...)
            
            # add marker if location is open
            if length(assignment[i]) > 0
                annotate!(locations[i,2], locations[i,3], text("O", 8))
            end
        end
    end
    
    # custom legend
    x_offset = minimum(customers[:,2]) + 0.9*(maximum(customers[:,2]) - minimum(customers[:,2]))
    y_offset = maximum(customers[:,3])
    offset = 0.25
    plot!([x_offset,x_offset], [y_offset,y_offset-offset], 
         linetype=:scatter, markersize=12, color="grey75", markerstrokewidth=0, markerstrokecolor="white")
    annotate!(x_offset, y_offset, text("O", 8))
    annotate!(x_offset+offset, y_offset, text("open", :left))
    annotate!(x_offset+offset, y_offset-offset, text("unused", :left))
    
    current()
end