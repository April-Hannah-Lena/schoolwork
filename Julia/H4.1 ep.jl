using BenchmarkTools

function makegreater1!(A)
    inds = findall(x -> x < 0, A)
    A[inds] .= 0 .- A[inds]
    return A
end

function makegreater2!(A)
    inds = A .< 0
    A[inds] .= 0 .- A[inds]
    return A
end

function makegreater3!(A)
    inds = Vector{eltype(CartesianIndices(A))}()
    for i in CartesianIndices(A)
        A[i] < 0 && push!(inds, i)
    end
    for i in inds
        A[i] = 0 - A[i] 
    end
    return A
end

mat = randn(100,100)
mat1 = copy(mat);  α =  makegreater1!(mat1)
mat2 = copy(mat); β =  makegreater2!(mat2)
mat3 = copy(mat); γ =  makegreater3!(mat3)
@btime makegreater1!($mat1)
@btime makegreater2!($mat2)
@btime makegreater3!($mat3)
α == β == γ