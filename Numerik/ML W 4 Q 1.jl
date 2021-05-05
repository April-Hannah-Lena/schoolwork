using CSV, LinearAlgebra, Statistics, DataFrames, Plots

X = convert(Array, CSV.read("C:\\Users\\april\\Documents\\schoolwork\\Numerik\\hitters.x.csv", DataFrame))
y = convert(Array, CSV.read("C:\\Users\\april\\Documents\\schoolwork\\Numerik\\hitters.y.csv", DataFrame))
y = [y[i, 1] for i in eachindex(y)]
n, d = size(X)
scale = 1 ./ sqrt.(var(X, dims=2)) |> flatten |> Diagonal
X, y = scale*X, scale*y

λ = 10 .^ range(-3, 7, length=100)
X = hcat(ones(n), X)
Ĩ = Diagonal([ 0; ones(d) ])
θ = [norm( (X'X + λ[i]Ĩ) \ X'y ) for i in eachindex(λ)]


Xy = sortslices(hcat(X, y), by=x -> rand(), dims=1)
X, y = Xy[:, 1:end-1], Xy[:, end]

i, k = 1, 5
m = round(Int, n / k, RoundDown)
err = Array{Float64,2}(undef, 100, k)
θ_cross = Array{Float64,2}(undef, d, k)

for i in 1:k
    val = m*(i-1) + 1 : m*i
    train = filter(j -> !(j in m*(i-1) + 1 : m*i), 1:n)
    X_val, y_val = X[val, :], y[val]
    X_train, y_train = X[train, :], y[train]

    θ = [ (X_train'X_train + λᵢ*Ĩ) \ X_train'y_train for λᵢ in λ ]
    err[:, i] = [ norm( y_val - X_val*θᵢ ) for θᵢ in θ ]
    θ_cross[:, i] = θ[argmin( err[:, i] )]
end

err = mean(err, dims=2)
θ_cross = mean(θ_cross, dims=2)



λ = 10 .^ range(-3, 7, length=100)
Ĩ = Diagonal([ 0; ones(d-1) ])
θ = [ (X'X + λᵢ*Ĩ) \ X'y for λᵢ in λ ]
open
using DelimitedFiles
y = readdlm("C:\\Users\\april\\Documents\\schoolwork\\Numerik\\hitters.y.csv", ',')