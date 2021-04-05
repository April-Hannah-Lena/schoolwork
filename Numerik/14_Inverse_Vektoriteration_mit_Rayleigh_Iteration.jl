using LinearAlgebra

function inverse_power_iteration(A,μ)
    normA = norm(A)                     # Frobenius-norm
    m = size(A,1)
    ω̃, λ, x = Inf, 0, rand(m)           # estimate of backward error, eigenpair
    #F = lu(A - μ*I)
    μ = μ0
    while ω̃ > m*eps()
        F = lu(A - μ*I)                   
        y = F\x
        z = x/norm(y)                   # hier könnte man noch etwas sparen ...
        x = y/norm(y)
        ρ = x'z                     
        λ = μ + ρ
        r = z - ρ*x
        μ = λ
        @show ω̃ = norm(r)/normA       
    end
    return λ, x
end

m = 3
A = [2 1 1; 1 3 1; 1 1 4]  #rand(m,m)
eigen(A)
μ0 = 5.
λ, x = inverse_power_iteration(A,μ0)
