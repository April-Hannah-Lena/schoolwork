using LinearAlgebra, SparseArrays, OffsetArrays, PaddedViews, Plots

function grid_solve((n, m)::Tuple{Int,Int}, f)
    len = (n-2) * (m-2)
    xrange = range(0, 1, m)[2:m-1]
    yrange = range(0, 1, n)[2:m-1]
    h = (xrange[2] - xrange[1] + yrange[2] - yrange[1]) / 2
    h = -1. / h^2
    A = h .* spdiagm(
        -1 => ones(len - 1), 
        0  => -4. .* ones(len),
        1  => ones(len - 1),
        -n => ones(len - n),
        n  => ones(len - n)
    )
    fx = vec(f.((x, y) for y in yrange, x in xrange))
    #u = A \ fx
    u = zeros(n, m)
    u[2:n-1, 2:m-1] .= reshape(A \ fx, (n-2,m-2))
    #return PaddedView(0., OffsetArray(reshape(u, (n-2,m-2)), 2:n-1, 2:m-1), (Base.OneTo(n), Base.OneTo(m)))
    return u
end

f((x,y)) = exp(pi * x * y)

u = grid_solve((100,100), x -> 10.)

surface(range(0, 1, 100), range(0, 1, 100), u)