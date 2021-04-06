# Aufgabe 23

Φ(x) = atan(2x)

x, k, TOL, θ = zeros(100), 2, eps(), 0.5
x[1:2] = [1, Φ(1)]
while abs(x[k]-x[k-1])/abs(x[k]) > (1-θ)/θ*TOL  && θ < 1
    k += 1
    x[k] = Φ(x[k-1])
    θ = abs(x[k]-x[k-1])/abs(x[k-1]-x[k-2])
end

using Plots
d = @. log10(abs(x[1:k]-x[k]) + eps())    # +eps(), um -Inf zu verhindern
plot(d)

# Aufgabe 26
using LinearAlgebra
using ForwardDiff: gradient, hessian

f(x) = (x[1]^2 + x[2] - 11)^2 + (x[1] + x[2]^2 - 7)^2  # Himmelblau function

∇f(x) = gradient(f,x)
Hf(x) = hessian(f,x)

k, x, h, h̄ = 0, 10*rand(2), [1,1], [0, 0]
while norm(h) > eps() 
    Z = lu(Hf(x))
    h = Z\∇f(x)
    τ = 1
    x = x - τ*h
    h̄ = Z\∇f(x)
    while norm(h̄) > norm(h) && τ > 2^-10
        @show τ /= 2
        x = x - τ*h
        h̄ = Z\∇f(x)
    end    
    k += 1
    @show abs(f(x)), norm(h), norm(h̄)
end
x, k

