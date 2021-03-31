include("graphs module.jl")
using Main.Graphs
using LinearAlgebra, ProgressMeter, Plots, PlotThemes
plotlyjs(); theme(:dark)

G = Dict(1=>[2, 3, 4, 4], 2=>[3, 4], 3=>[4],  4=>Int64[])
g = Graph(G)
F = spantree(g; by = e -> norm(e[1]-e[2]))

V = [randn(3) for i in 1:16]
A = ones(Bool, 16, 16) - I .|> Bool
g = Graph(V, A)
plot(g)
g0 = unidirectional_Digraph(g)
g0 = spantree(g; by = e -> norm(e[1]-e[2]))
g0 = cluster(g, 3; by = e -> norm(e[1]-e[2]))
plot(g0)

n = 250
V = [2 .* randn(3) for i in 1:n]
A = rand(n, n) + I
A = A .< 0.05
g = Graph(V, A)
plot(g)
d, p = shortest_path(g, g.V[end-1]; by=e -> norm(e[1] - e[2]))
g0 = spantree(g, by=e -> norm(e[1]-e[2]))
plot(g0)
u = g.V[argmax(map(v -> norm(v - zeros(3)), g.V))]; w = g.V[argmax(map(v -> norm(v - u), g.V))]
path = shortest_path(g0, u, w; by=e -> norm(e[1] - e[2]))
scatter([getindex.(g.V, j) for j in eachindex(g.V[1])]..., markeralpha=0.6, leg=false)
plot!([getindex.(path, j) for j in eachindex(path[1])]..., linewidth=8, linealpha=0.9)
savefig("shortest path.html")