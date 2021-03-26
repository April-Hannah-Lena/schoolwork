using LinearAlgebra, ProgressMeter
using Pipe: @pipe
import Base: show, display, sort!, size

module Graphs

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
Digraph(V::Array{T,1}, A::Array{Bool,2}) where T<:Any = begin
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
Graph(V::Array{T,1}, A::Array{Bool,2}) where T<:Any = begin
    A[A .!= A'] .= 1
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
    typeof(g)(g_new.V, g_new.E)
end

function spantree(g::G; kwargs...) where G <: AbstractGraph
    edges = sort!(g; kwargs...)
    F = F_new = typeof(g)(Dict{eltype(g.V), Array{eltype(g.V),1}}())
    k, n = 1, size(connected_vertices(g), 1)
    p = Progress(n, 1)
    while size(F, 1) < n
        F_new = add_edge(edges[k], F)
        if size(F_new, 1) == size(F_new, 2) + 1
            F = F_new
            filter!(e -> e != edges[k], edges)
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

end