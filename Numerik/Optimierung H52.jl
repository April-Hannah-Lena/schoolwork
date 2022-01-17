using LinearAlgebra

A = [0  1  0;
     0  0  1;
     1 -1 -1;
     3  2  2;
     -1 0  0;
     0 -1  0;
     0  0 -1]
b = [6, 9, 3, 24, 0, 0, 0]
x⁰ = [0, 0, 9]
function e(j, n)
    e = zeros(n)
    e[j] = 1
    return e
end

function simplex(A, b, c, x⁰) # funktioniert nur wenn rg(Aₐ₀)=3
    n, m = size(A)
    A_tmp = []
    λ, s, j, x = [-1], [1], 0, []
    σ = 0

    A_aktiv = findall(A*x⁰ .== b)
    A_work = A_aktiv[1:length(c)]
    λ = A_work' \ -c
    

    while any(λ .< 0)
        j = findfirst(λ .< 0)
        s = A[A_work] \ -(e(j, n)[A_work])
        if any(A[A_aktiv] * s .> 0)
            j = findfirst(A[filter(x -> x !== j, A_work), :] * s .== 0)
            i = findfirst(i -> (A[i, :])' * s !== 0, filter(x -> !(x in A_work), A_aktiv))
            A_work = push!(filter(x -> x !== j, A_work), i)
        elseif all(A * s .≤ 0)
            return x
        else
            A_tmp = hcat((b .- (A * x)) ./ (A * s), A * s .> 0)
            σ = minimum(i -> begin
                                A_tmp[i, 2] == 0 && return Inf
                                A_tmp[i, 2] == 1 && return A_tmp[i, 1]
                             end,
                        collect(1:n))
            end
            i = argmin()

                



        