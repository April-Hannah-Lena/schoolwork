using LinearAlgebra, Plots, SpecialFunctions
theme(:dark)

# liefert die Gauß-Knoten und Gewichte auf [-1,1]
function Gauß(n)
    k = 1:n
    β = @. k/sqrt((2*k-1)*(2*k+1))
    T = SymTridiagonal(zeros(n+1),β)
    λ, Q = eigen(T)     # λ = Knoten 
    w = 2*Q[1,:].^2     # Gewichte
    return λ, w     
end

@time Gauß(1000);

f(x) = x.^40; If = 2/41
ε = zeros(51)
for n = 0:50
    x, w = Gauß(n)
    ε[n+1] = abs(If - w'*f(x))
end

plot(0:50, ε, yaxis=:log, marker=:dot, ylim=(1e-18,1))