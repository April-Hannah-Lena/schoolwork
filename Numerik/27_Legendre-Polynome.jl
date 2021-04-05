using SymPy

@vars x                                  # x als symbolische Variable deklarieren
a, b = -1,1
dot(f,g) = integrate(f(x)*g(x),(x,a,b))   # L²-Skalarprodukt
norm(f) = sqrt(dot(f,f))                        # zugehörige Norm

α, β, p = zeros(Sym,10), zeros(Sym,10), zeros(Sym,10)

# Lanczos iteration
α[1], β[1] = 0, 0
p[1] = 1
p[1] = p[1]/norm(p[1])

α[2] = dot(x*p[1], p[1]) 
p[2] = x*p[1] - α[2]*p[1]
p[2] = p[2]/norm(p[2])

for k = 2:9
    α[k+1] = dot(x*p[k], p[k])
    β[k]   = dot(x*p[k-1], p[k])
    p[k+1] = x*p[k] - α[k+1]*p[k] - β[k]*p[k-1]
    p[k+1] = p[k+1]/norm(p[k+1])
end
simplify(p[5])