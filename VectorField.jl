using Plots, LinearAlgebra


meshgrid(x, y) = [repeat(x, outer=length(y)) repeat(y, inner=length(x))]
# takes two Arrays, one of x values, one of y values
# meshgrid(x <: AbstractArray{<:Number,1}, y <: AbstractArray{<:Number,1})

function vectorfield(field, points, arrowscale=0.1)
    vectors = similar(points)
    d = size(points, 1)
    for i in 1:d
        vectors[i, :] .= collect(field(points[i, :]...))
    end
    vectors .*= arrowscale
    quiver(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end
# field is a Function that takes d inputs. d = dimension = 2 (3d not supported by Plots)
# points is an Array of size dx2, each row represents a point in space 
# vectorfield2d(field::Function, points <: AbstractArray{<:Number,2}, arrowscale::Real=0.1)

function vectorfield!(field, points, arrowscale=0.1)
    vectors = similar(points)
    d = size(points, 1)
    for i in 1:d
        vectors[i, :] .= collect(field(points[i, :]...))
    end
    vectors .*= arrowscale
    quiver!(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end
# identical, but plots over existing items.
# to keep in line with Plots formatting