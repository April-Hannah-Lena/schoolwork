using LinearAlgebra

function inverse_power_iteration(A,μ)
    normA = norm(A)                     # Frobenius-norm
    λ̄ = [0.]
    m = size(A,1)
    ω̃, λ, x = Inf, 0, [1., 1., 1., 1.]          # estimate of backward error, eigenpair
    F = lu(A - μ*I)
    while ω̃ > m*eps()                   
        y = F\x
        z = x/norm(y)                   # hier könnte man noch etwas sparen ...
        x = y/norm(y)
        ρ = x'z                     
        λ = μ + ρ
        push!(λ̄, λ)
        r = z - ρ*x
        @show ω̃ = norm(r)/normA       
    end
    return λ̄, x
end

m = 4
A1 = float.([-3 0 0 0;
      0 -2 0 0;
      0 0 -1 0;
      0 0 0 3])
A2 = float.([-3 0 0 0;
      0 -1 0 0;
      0 0 0 0;
      0 0 0 3])
A3 = float.([-3 0 0 0;
      0 -1 0 0;
      0 0 1 0;
      0 0 0 3])
eigen(A1)
eigen(A2)
F3 = eigen(A3)
F3.vectors
μ = 2.
λ1, x1 = inverse_power_iteration(A1,μ)
λ2, x2 = inverse_power_iteration(A2,μ)
λ3, x3 = inverse_power_iteration(A3,μ)
