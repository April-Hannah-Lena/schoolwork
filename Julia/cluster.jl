using LinearAlgebra
using Pipe: @pipe

# E (Kanten) sind in Form von Matrix mit ein Ende in 1. Spalte, anderes Ende in 2. Spalte
vertices(E) = vcat(E[:, 1], E[:, 2]) |> unique!
function sortedges(E; weight=norm, rev=false)
    E = [[E[i, 1], E[i, 2]] for i in 1:size(E, 1)] # convert to array
    E = sort!(E, by = e -> weight(e[1] - e[2]), rev=rev) # sort array
    E = @pipe hcat.(E) |> permutedims.(_) |> vcat(_...) # convert back to matrix
    return E
end
function spantree(E; weight=norm, rev=false) # kruskal algorithm
    E = sortedges(E; weight=weight, rev=rev)
    V = vertices(E); n = size(V, 1)
    W = W_new = Array{Array{Float64, 1}, 1}(undef, 0)
    F = F_new = Array{Array{Float64, 1}, 2}(undef, 0,2)
    k = 1; m = size(E, 1) + 1
    while size(F, 1) < n - 1 && k < m
        F_new = vcat(F, permutedims(E[k, :]))
        W_new = vertices(F_new)
        if size(F_new, 1) == size(W_new, 1) - 1
            F = F_new
            W = W_new
            k = 1
        else 
            k += 1
        end
    end
    if k == m
        error("Graph isn't connected")
    else
        return F
    end
end
function alledges(V) # this would be a one-liner if julia's 
    n = length(V) # array comprehension were better
    E = Array{Array{Float64, 1}, 2}(undef, 0,2)
    for i in 1:n-1, j in i+1:n
        E = vcat(E, [[V[i]] [V[j]]])
    end
    return E
end
function cluster(V, k)
    T = V |> alledges |> spantree |> sortedges
    return T[1:size(V, 1) - k, :] # choose the |V|-k shortest edges
end


using Plots, PlotThemes
plotlyjs()
theme(:dark)

m = 3
V = [5 .* randn(m) for i in 1:500]
E = cluster(V, 1)
V̄ = [getindex.(V, j) for j in 1:m]
fig = scatter(V̄..., markeralpha=0.6, leg=false)
for i in 1:size(E, 1)
    Ē = [getindex.(E[i, :], j) for j in 1:m]
    plot!(fig, Ē..., linewidth=4, linealpha=0.8)
end
display(fig)
savefig("cluster-dark.html")