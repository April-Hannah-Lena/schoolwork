using Plots, PlotThemes, LinearAlgebra
using ForwardDiff: gradient, hessian

function vectorfield2d(field, points, arrowlength=0.1)
    # More input pattern parsing is solved by the Plots package, but I don't know how.
    errormessage = "Incorrect formatting of points. Please format them as [x1 y1; x2, y2;...]"
    
    if typeof(points) <: Array{<:Number, 2} && size(points)[1] === 2
        vectors = similar(points)
        for i in 1:size(points)[2]
            vectors[:, i] .= collect(field(points[:, i]...))
        end
    else
        error(errormessage)
    end
    vectors .*= arrowlength
    quiver(points[1, :],points[2, :],quiver=(vectors[1, :], vectors[2, :]))
    display(plot!())
end
        
function meshgrid(n)
    xs = ones(n) .* (1:n)'
    ys = xs'
    xys = permutedims(cat(xs, ys; dims = 3), [3, 1, 2])
    return reshape(xys, 2, n^2)
end

g(x) = (x[1]^2 + x[2] - 11)^2 + (x[1] + x[2]^2 - 7)^2  # Himmelblau function
Df(x, y) = normalize(gradient(g, [x,y])) .* 2

grid = meshgrid(20) ./ 2 .- [5;5]
vectorfield2d(Df, grid)