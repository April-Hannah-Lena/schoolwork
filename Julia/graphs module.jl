module Graphs

import LinearAlgebra: norm, UpperTriangular
import ProgressMeter: Progress, next!
import Base: show, display, sort, size, similar
import Core: Array
import Plots: plot, plot!, scatter, scatter!
export AbstractGraph, Digraph, Graph, size, δ, neighbors, show, display, sort, connected_vertices, adjacency_matrix, add_edge, spantree, cluster, plot, unidirectional_Digraph, Array, shortest_path, similar, is_connected

Array(e::Tuple{T, T}) where T<:Any = [v for v in e]

abstract type AbstractGraph end

mutable struct Digraph{T<:Any} <: AbstractGraph
    V :: Array{T, 1}
    E :: Array{Tuple{T, T}, 1}
    Digraph{T}(V, E) where T<:Any = begin 
        V, E = unique!.([V, E])
        new(V, E)
    end
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
    Graph{T}(V, E) where T<:Any = begin
        V, E = unique!.([V, vcat(E, reverse.(E))])
        new(V, E)
    end
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

sort(g::G; kwargs...) where G <: AbstractGraph = sort(g.E; kwargs...)
connected_vertices(g::G) where G <: AbstractGraph = vcat(getindex.(g.E, 1), getindex.(g.E, 2)) |> unique!
connected_vertices(E::Array{Tuple{T,T},1}) where T<:Any = vcat(getindex.(E, 1), getindex.(E, 2)) |> unique!
adjacency_matrix(g::G) where G <: AbstractGraph = vcat([[w ∈ neighbors(v, g) for w in g.V]' for v in g.V]...)
similar(g::G) where G <: AbstractGraph = typeof(g)(Array{eltype(g.V),1}(undef, 0), Array{Tuple{eltype(g.V), eltype(g.V)},1}(undef, 0))

function add_edge(e, g::G) where G <: AbstractGraph
    E_new = vcat(g.E, e)
    V_new = vcat(g.V, connected_vertices(E_new))
    typeof(g)(V_new, E_new)
end

function spantree(g::G; kwargs...) where G <: AbstractGraph
    edges = sort(g; kwargs...)
    F = F_new = similar(g)
    k, n = 1, size(connected_vertices(g), 1)
    prog = Progress(n, 1)
    while size(F, 1) < n && size(edges, 1) > 0
        F_new = add_edge(edges[k], F)
        if size(F_new, 1) == size(F_new, 2) + 1
            F = F_new
            edges = filter(e -> !(e in [edges[k], reverse(edges[k])]), edges)
            next!(prog)
            k = 1
        elseif k < size(edges, 1)
            k += 1
        else
            @warn "Graph is not connected"
            break
        end
    end
    F.E = sort(F; kwargs...)
    return F
end

function cluster(g::G, n; kwargs...) where G <: AbstractGraph
    T = spantree(g; kwargs...) |> unidirectional_Digraph
    T = typeof(g)(T.V, T.E[1 : size(T, 1) - n])
end

function unidirectional_Digraph(g::Graph{T}) where T<:Any
    A = g |> adjacency_matrix |> UpperTriangular |> Matrix
    return Digraph(g.V, A)
end

function plot(g::Digraph{T}; markeralpha=0.6, leg=false, linewidth=4, linealpha=0.6, kwargs...) where T<:Any
    e0 = []
    V = [getindex.(g.V, j) for j in eachindex(g.V[1])]
    fig = scatter(V..., markeralpha=markeralpha, leg=leg, kwargs...)
    for e in g.E
        e0 = [getindex.(Array(e), j) for j in eachindex(e[1])]
        fig = plot!(fig, e0..., linewidth=linewidth, linealpha=linealpha, kwargs...)
    end
    return fig
end
function plot(g::Graph{T}; markeralpha=0.6, leg=false, linewidth=4, linealpha=0.6, kwargs...) where T<:Any
    g0 = unidirectional_Digraph(g); e0 = []
    V = [getindex.(g0.V, j) for j in eachindex(g0.V[1])]
    fig = scatter(V..., markeralpha=markeralpha, leg=leg, kwargs...)
    for e in g0.E
        e0 = [getindex.(Array(e), j) for j in eachindex(e[1])]
        fig = plot!(fig, e0..., linewidth=linewidth, linealpha=linealpha, kwargs...)
    end
    return fig
end

function shortest_path(g::G, s; by=e->1) where G <: AbstractGraph
    d = Dict(s=>0, [v=>Inf for v in filter(u -> u != s, g.V)]...)
    p = Dict([v=>[] for v in g.V]...)
    v, w, δ, V, R, E = s, s, Inf, g.V, [], []
    prog = Progress(size(V, 1), 1)
    while size(V, 1) > 0
        v = V[argmin(map(u -> d[u], V))]
        R = push!(R, v)
        V = filter(u -> !(u in R), V)
        E = filter(e -> e[1] == v && e[2] in V, g.E)
        for e in E
            w = e[2]
            δ = d[v] + by(e)
            if d[w] > δ
                d[w] = δ
                p[w] = v
            end
        end
        next!(prog)
    end
    return d, p
end
function shortest_path(g::G, s, t; by=e->1) where G <: AbstractGraph
    d, p = shortest_path(g, s; by)
    d[t] < Inf ? nothing : error("no path from $s to $t")
    v, path = t, [t]
    while v != s
        path = pushfirst!(path, p[v])
        v = path[1]
    end
    return path
end
function is_connected(g::G) where G <: AbstractGraph
    d, p = shortest_path(g, g.V[1])
    return Inf in values(d)
end

end