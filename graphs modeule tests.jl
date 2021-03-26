include("graphs module.jl")
using Main.Graphs
using LinearAlgebra, ProgressMeter

G = Dict(1=>[2, 3, 4, 4], 2=>[3, 4], 3=>[4],  4=>Int64[])
g = Graph(G)
F = spantree(g; by = e -> norm(e[1]-e[2]))

V = [rand(3) for i in 1:20]
A = ones(Bool, 20, 20) - I .|> Bool
g = Graph(V, A)
plot(g)