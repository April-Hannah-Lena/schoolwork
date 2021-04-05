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
# points is an Array of size 2xd, each column represents a point in space 
# vectorfield2d(field::Function, points <: AbstractArray{<:Number,2}, arrowscale::Real=0.1)

function vectorfield!(points, field::Function; arrowscale=0.1)
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
    vectors .*= arrowscale
    quiver(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end
# u, v are 2 matrices, the value of u[i, j] is the x component of the arrow, 
# the value of v[i, j] is the y component of the arrow
# Grid will be interpolated as:
#     ys - >           ys - >
# xs                xs
# |    u            |    v
# v           ,     v

function vectorfield!(xs, ys, u::T, v::T; arrowscale=0.1) where {T <: AbstractArray{<:Number,N} where N}
    points = meshgrid(xs, ys)
    d = size(points, 2)
    d == length(u) == length(v) || error("Dimensions do not match. Ensure length(u)==length(v)==length(xs)*length(ys)")
    vectors = [reshape(u', 1, :); reshape(v', 1, :)]
    vectors .*= arrowscale
    quiver!(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end

function vectorfield(xs, ys, uv::T; arrowscale=0.1) where {T <: AbstractArray{S,N} where S where N}
    points = meshgrid(xs, ys)
    d = size(points, 2)
    u = [uv[i][1] for i in CartesianIndices(uv)]
    v = [uv[i][2] for i in CartesianIndices(uv)]
    d == length(u) == length(v) || error("Dimensions do not match. Ensure length(u)==length(v)==length(xs)*length(ys)")
    vectors = [reshape(u', 1, :); reshape(v', 1, :)]
    vectors .*= arrowscale
    quiver(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end
# uv is a matrix of 2-element arrays [x, y]. Arrows will be interpreted componentwise.
# Grid will be interpolated as:
#     ys - >
# xs
# |    uv
# v

function vectorfield!(xs, ys, uv::T; arrowscale=0.1) where {T <: AbstractArray{S,N} where S where N}
    points = meshgrid(xs, ys)
    d = size(points, 2)
    u = [uv[i][1] for i in CartesianIndices(uv)]
    v = [uv[i][2] for i in CartesianIndices(uv)]
    d == length(u) == length(v) || error("Dimensions do not match. Ensure length(u)==length(v)==length(xs)*length(ys)")
    vectors = [reshape(u', 1, :); reshape(v', 1, :)]
    vectors .*= arrowscale
    quiver!(points[1, :], points[2, :], quiver=(vectors[1, :], vectors[2, :]))
end