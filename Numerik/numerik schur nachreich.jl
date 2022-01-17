using LinearAlgebra

function inverse_power_iteration(A, µ)
    normA = norm(A)
    m = size(A, 1)
    ω, λ, x = Inf, 0, rand(m)
    F = lu(A - µ*I)

    while ω > m * eps()
        y = F \ x
        z = x / norm(y)
        x = y / norm(y)
        ρ = x'z
        λ = µ + ρ
        r = z - ρ*x
        @show ω = norm(r) / normA
    end

    return λ, x
end

m = rand(5:15)
A = rand(m, m) + rand(m, m) * im
µ = rand() + rand() * im
F = schur(A)
x = F.T[1:1]

for i in 1:m
    norm(µ - A[i, i]) < norm(x) ? x = µ : nothing
end
@show x

x, v = inverse_power_iteration(A, x)
