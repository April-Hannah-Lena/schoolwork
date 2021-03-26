include("graphs module.jl")
using Main.Graphs
using LinearAlgebra, ProgressMeter, Plots, PlotThemes
plotlyjs(); theme(:dark)

G = Dict(1=>[2, 3, 4, 4], 2=>[3, 4], 3=>[4],  4=>Int64[])
g = Graph(G)
F = spantree(g; by = e -> norm(e[1]-e[2]))

V = [randn(3) for i in 1:30]
A = ones(Bool, 30, 30) - I .|> Bool
g = Graph(V, A)
plot(g)
g0 = unidirectional_Digraph(g)
g0 = spantree(g; by = e -> norm(e[1]-e[2]))
g0 = cluster(g, 3; by = e -> norm(e[1]-e[2]))
plot(g0)
