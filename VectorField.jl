using Plots, LinearAlgebra


function meshgrid(x, y)
    x, y = float.(x), float.(y)
    [repeat(x, inner=length(y))'; repeat(y, outer=length(x))']
end

function vectorfield(points, field::Function; arrowscale=0.1)
    vectors = similar(points)
    d = size(points, 2)
    for i in 1:d
        vectors[:, i] .= collect(field(points[:, i]...))
    end
    vectors .*= arrowscale
    quiver(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end
# field is a Function that takes d inputs. d = dimension = 2 (3d not supported by Plots - use Makie.jl)
# points is an Array of size dx2, each row represents a point in space 
# vectorfield2d(field::Function, points <: AbstractArray{<:Number,2}, arrowscale::Real=0.1)

function vectorfield!(points, field::Funtion; arrowscale=0.1)
    vectors = similar(points)
    d = size(points, 2)
    for i in 1:d
        vectors[:, i] .= collect(field(points[:, i]...))
    end
    vectors .*= arrowscale
    quiver!(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end
# identical, but plots over existing items.
# to keep in line with Plots formatting

function vectorfield(xs, ys, field::Function; arrowscale=0.1)
    points = meshgrid(xs, ys)
    vectors = similar(points)
    d = size(points, 2)
    for i in 1:d
        vectors[:, i] .= collect(field(points[:, i]...))
    end
    vectors .*= arrowscale
    quiver(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end
# input x and y ranges, grid is interpolated

function vectorfield!(xs, ys, field::Function; arrowscale=0.1)
    points = meshgrid(xs, ys)
    vectors = similar(points)
    d = size(points, 2)
    for i in 1:d
        vectors[:, i] .= collect(field(points[:, i]...))
    end
    vectors .*= arrowscale
    quiver!(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end

function vectorfield(xs, ys, u::T, v::T; arrowscale=0.1) where {T <: AbstractArray{<:Number,N} where N}
    points = meshgrid(xs, ys)
    d = size(points, 2)
    d == length(u) == length(v) || error("Dimensions do not match. Ensure length(u)==length(v)==length(xs)*length(ys)")
    vectors = [reshape(u', 1, :); reshape(v', 1, :)]
    for i in 1:d
        vectors[:, i] .= collect(field(points[:, i]...))
    end
    vectors .*= arrowscale
    quiver(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end
# u, v are 2 matrices. Grid will be interpolated as:
#     ys - >           ys - >
# xs                xs
# |    u            |    v
# v           ,     v

function vectorfield!(xs, ys, u::T, v::T; arrowscale=0.1) where {T <: AbstractArray{<:Number,N} where N}
    points = meshgrid(xs, ys)
    d = size(points, 2)
    d == length(u) == length(v) || error("Dimensions do not match. Ensure length(u)==length(v)==length(xs)*length(ys)")
    vectors = [reshape(u', 1, :); reshape(v', 1, :)]
    for i in 1:d
        vectors[:, i] .= collect(field(points[:, i]...))
    end
    vectors .*= arrowscale
    quiver!(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end