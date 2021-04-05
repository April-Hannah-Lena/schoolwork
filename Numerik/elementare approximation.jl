using Plots, PlotThemes, Polynomials
theme(:dark)

function chebycheff(f, n)
    itr = []
    x = cos.(k * π / n for k in 0:1:n)                    # Chebycheff Knoten

    λ = [ prod([1/(x[1]-x[k]) for k in 2:1:n+1]) ]        # Baryzentrische Gewichte
    for j in 2:n
        itr = push!(Array(1:j-1), j+1:n+1 ...)
        push!(λ, prod([1/(x[j]-x[k]) for k in itr]))
    end
    push!(λ, prod([1/(x[n+1]-x[k]) for k in 1:n]))

    ω(z) = prod(z - x[k] for k in 1:n+1)                  # ω_n+1

    cheb(z) = ω(z) .* sum( f(x[k]) * λ[k] / (z - x[k]) for k in 1:1:n+1 )
    return x, cheb
end

n=30
f(x) = 5 * cos(3*x) * exp(- (3*x)^2 / 2)
x, cheb = chebycheff(f, n)

p = plot(f, xlims=(-1, 1), ylims=(-1, 5))
p = scatter!(x, f.(x))
p = plot!(cheb)
