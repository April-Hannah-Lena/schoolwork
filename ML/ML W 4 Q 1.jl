using DelimitedFiles, LinearAlgebra, Statistics, Plots
cd("C:\\Users\\april\\Documents\\schoolwork\\Numerik")
flatten(x) = [x[i] for i in eachindex(x)]

X, headers = readdlm("hitters.x.csv", ',', header=true)
y = readdlm("hitters.y.csv", ',', skipstart=1)
n, d = size(X)
# .- mean(y)  .- mean(X, dims=2)
y = (y) ./ sqrt.(var(y))
X = (X) ./ sqrt.(var(X, dims=2))

X, d = hcat(ones(n), X), d+1
Ĩ = Diagonal([ 0; ones(d-1) ])

λ = 10 .^ range(-3, 7, length=100)                                 # log range
θ = [(X'X + λᵢ*Ĩ) \ X'y for λᵢ in λ]                               # solve

fig1 = plot(λ, collect(eachrow(hcat(θ...))),
            xaxis=:log10, yaxis=((-10, 10), "Elements of θ"), lab=false)

θ = norm.(θ)
fig2 = plot(λ, θ, xaxis=:log10, yaxis=(:log10, "|| θ ||"), lab="ridge regression")
fig2 = hline!([norm( X'X \ X'y )], linestyle=:dash, lab="least squares regression")

fig = plot(fig1, fig2, layout=2, size=(800, 400), margin=5Plots.mm)

Xy = sortslices(hcat(X, y), by=x -> rand(), dims=1)
X, y = Xy[:, 1:end-1], Xy[:, end]

k = 5                                                              # initialize
m = round(Int, n / k, RoundDown)
err = zeros(100, k)
θ_cross = zeros(d, k)

for i in 1:k                                                       # split dataset
    val = m*(i-1) + 1 : m*i                                        # into k parts
    train = filter(j -> !(j in val), 1:n)
    X_train, y_train = X[train, :], y[train]               

    θ = [ (X_train'X_train + λᵢ*Ĩ) \ X_train'y_train for λᵢ in λ ] # train model
    err[:, i] = [ norm( y[val] - X[val, :]*θᵢ ) for θᵢ in θ ]
    θ_cross[:, i] = θ[argmin( err[:, i] )]                         # save best result
end

err = mean(err, dims=2)                                            # average error
fig = plot(λ, err, xaxis=(:log10, "λ"), yaxis=:log10,
           leg=:outertopright, lab="mean error")
fig = vline!([λ[argmin(err)]], linestyle=:dash, lab="best λ")

θ_cross = mean(θ_cross, dims=2)


using DelimitedFiles, LinearAlgebra, Plots, Statistics
cd("C:\\Users\\april\\Documents\\schoolwork\\Numerik")
X, headers = readdlm("hitters.x.csv", ',', header=true)
y = readdlm("hitters.y.csv", ',', skipstart=1)
n, d = size(X)

y = (y .- mean(y)) ./ std(y)
X = (X .- mean(X, dims=1)) ./ std(X, dims=1)
X = hcat(ones(n), X)

function ridge(X, y, λ)
    Ĩ = I(size(X, 2)); Ĩ[1, 1] = 0
    return ( X'X + λ*Ĩ ) \ X'y
end

λs = 10 .^ range(-3, 7, length=100)
θs = [ridge(X, y, λ) for λ in λs]
Ĩ = I(size(X, 2)); Ĩ[1, 1] = 0
norm_θs = norm.([Ĩ * θ for θ in θs])
plot(norm_θs, xscale=:log10, yscale=:log10)

function cv_ridge(X, y, λ, k=5)
    n = size(X, 1)
    n % k == 0 ? (m = n/k) : (m = round(Int, n/k, RoundDown))
    Xy = sortslices(hcat(X, y), dims=1, by=x -> rand())
    X̄, ȳ = Xy[:, 1 : end-1], Xy[:, end]
    θ, errors = Float64[], Float64[]

    for i in 1:k
        val = m*(i-1) + 1 : m*i
        train = filter(j -> !(j in val), 1:n)

        θ = ridge(X̄[train, :], ȳ[train], λ)
        errors = push!(errors, norm( ȳ[val] - X̄[val, :] * θ ))
    end

    return mean(errors)
end

cv_errors = [cv_ridge(X, y, λ) for λ in λs]
plot(λs, cv_errors, xscale=:log10)
θ_best = ridge(X, y, λs[argmin(cv_errors)])
p = sortperm(flatten(θ_best), rev=true)
permutedims(hcat("bias", headers)[p])