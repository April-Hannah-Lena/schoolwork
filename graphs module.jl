module Graphs

import LinearAlgebra: norm
import ProgressMeter: Progress, next!
import Base: show, display, sort!, size
import Plots: plot, plot!, scatter, scatter!
export AbstractGraph, Digraph, Graph, size, δ, neighbors, show, display, sort!, connected_vertices, adjacency_matrix, add_edge, spantree, cluster, plot

abstract type AbstractGraph end

mutable struct Digraph{T<:Any} <: AbstractGraph
    V :: Array{T, 1}
    E :: Array{Tuple{T, T}, 1}
    Digraph{T}(V, E) where T<:Any = new(unique!(V), unique!(E))
end
Digraph(V::Array{T,1}, E::Array{Tuple{T,T},1}) where T<:Any = Digraph{T}(V, E)
Digraph(G::Dict{T, Array{T,1}}) where T<:Any = begin
    V = keys(G) |> collect
    E = [[(v, w) for w in G[v]] for v in V]
    E = vcat(E...)
    Digraph(V, E)
end
Digraph(V::Array{T,1}, A::B) where T<:Any where B <: Union{Array{Bool,2},BitArray{2}} = begin
    E = Array{Tuple{T, T}, 1}(undef, 0)
    i, j = 0, 0
    for ci in CartesianIndices(A)
        i, j = Tuple(ci)
        A[i, j] == 1 ? push!(E, (V[i], V[j])) : nothing
    end
    Digraph(V, E)
end

mutable struct Graph{T<:Any} <: AbstractGraph
    V :: Array{T, 1}
    E :: Array{Tuple{T, T}, 1}
    Graph{T}(V, E) where T<:Any = new(unique!(V), unique!(vcat(E, reverse.(E))))
end
Graph(V::Array{T,1}, E::Array{Tuple{T,T},1}) where T<:Any = Graph{T}(V, E)
Graph(G::Dict{T, Array{T,1}}) where T<:Any = begin
    V = keys(G) |> collect
    E = [[(v, w) for w in G[v]] for v in V]
    E = vcat(E...)
    Graph(V, E)
end
Graph(V::Array{T,1}, A::B) where T<:Any where B <: Union{Array{Bool,2},BitArray{2}} = begin
    A[A .!= A'] .= true
    E = Array{Tuple{T, T}, 1}(undef, 0)
    i, j = 0, 0
    for ci in CartesianIndices(A)
        i, j = Tuple(ci)
        A[i, j] == 1 ? push!(E, (V[i], V[j])) : nothing
        i == j && A[i, j] == 1 ? push!(E, (V[j], V[i])) : nothing
    end
    Graph(V, E)
end

size(g::Digraph{T}) where T<:Any = (length(g.V), length(g.E))
size(g::Graph{T}) where T<:Any = (length(g.V), Int64(length(g.E)/2))
size(g::G, d::Core.Integer) where G <: AbstractGraph = size(g)[d]

δ(v, g::G) where G <: AbstractGraph = filter(e -> e[1] == v, g.E)
neighbors(v, g::G) where G <: AbstractGraph = getindex.(δ(v, g), 2)
show(g::G) where G <: AbstractGraph = (v=>neighbors(v, g) for v in g.V) |> Dict |> show
function display(g::G) where G <: AbstractGraph
    println("$(typeof(g)) with $(size(g, 1)) vertices, $(size(g, 2)) edges:")
    for v in g.V
        println("$v => ", neighbors(v, g))
    end
end

sort!(g::G; kwargs...) where G <: AbstractGraph = sort!(g.E; kwargs...)
connected_vertices(g::G) where G <: AbstractGraph = vcat(getindex.(g.E, 1), getindex.(g.E, 2)) |> unique!
connected_vertices(E::Array{Tuple{T,T},1}) where T<:Any = vcat(getindex.(E, 1), getindex.(E, 2)) |> unique!
adjacency_matrix(g::G) where G <: AbstractGraph = vcat([[w ∈ neighbors(v, g) for w in g.V]' for v in g.V]...)

function add_edge(e, g::G) where G <: AbstractGraph
    E_new = vcat(g.E, e)
    V_new = vcat(g.V, connected_vertices(E_new))
    typeof(g)(V_new, E_new)
end

function spantree(g::G; kwargs...) where G <: AbstractGraph
    edges = sort!(g; kwargs...) |> copy
    F = F_new = typeof(g)(Array{eltype(g.V),1}(undef, 0), Array{Tuple{eltype(g.V), eltype(g.V)},1}(undef, 0))
    k, n = 1, size(connected_vertices(g), 1)
    p = Progress(n, 1)
    while size(F, 1) < n && size(edges, 1) > 0
        F_new = add_edge(edges[k], F)
        if size(F_new, 1) == size(F_new, 2) + 1
            F = F_new
            edges = filter(e -> !(e in [edges[k], reverse(edges[k])]), edges)
            next!(p)
            k = 1
        elseif k < size(edges, 1)
            k += 1
        else
            break
        end
    end
    F.E = sort!(F; kwargs...)
    return F
end

function cluster(g::G, n; kwargs...) where G <: AbstractGraph
    T = spantree(g; kwargs...)
    T = typeof(g)(T.V, T.E[1:n])
end

function plot(g::G; kwargs...) where G <: AbstractGraph
    V = [getindex.(g.V, j) for j in eachindex(g.V[1])]
    fig = scatter(V..., markeralpha=0.6, leg=false, kwargs...)
    for e in g.E
        e = [getindex.(e, j) for j in eachindex(e[1])]
        plot!(fig, e..., linewidth=4, linealpha=0.6, kwargs...)
    end
    return fig
end


end