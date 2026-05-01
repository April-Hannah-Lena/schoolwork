using LinearAlgebra, Statistics
using Plots, LaTeXStrings
using Plots: mm
using ProgressMeter
using DataFrames, CSV, Impute, Dates

variable = "apcp"
#"evp",
#"pevap",
#"pevpr",
#"soilm",
#"ssrun",
#"tsoil",
#"lai",
#"pna",
#"nao",
#"ao",
#"enso"


dataset = CSV.read("/Users/april/Downloads/usdm_dataset.csv", DataFrame, missingstring="NA", types=Dict(:time => Date), dateformat="yyyymmdd", select=["time", "lat", "lon", variable])
dataset = dataset |> Impute.interp() |> Impute.locf() |> Impute.nocb() |> dropmissing!


groups = groupby(dataset[3 .≤ month.(dataset[!,:time]) .≤ 5, :], :time)
data_matrix = stack(group[!,variable] for group in groups)

means, stds = mean(data_matrix, dims=1), std(data_matrix, dims=1)
data_matrix .-= means
data_matrix ./= stds


X = data_matrix[1:end-1, :]
Y = data_matrix[2:end, :]

kernel(x,y, c=100) = exp(-norm(x - y)^2 / c)

Ĝ = @showprogress [kernel(x1,x2) for x1 in eachrow(X), x2 in eachrow(X)]
Â = @showprogress [kernel(y1,x2) for y1 in eachrow(Y), x2 in eachrow(X)]
Ĵ = @showprogress [kernel(y1,y2) for y1 in eachrow(Y), y2 in eachrow(Y)]

σ, Q = eigen(Ĝ)
r = 400#sum(σ .> 1e-4)

Σ̃ = Diagonal( sqrt.(σ[end-r+1:end]) )
Q̃ = Q[:, end-r+1:end]

Σ̂⁺ = inv(Σ̃)
K̂ = (Σ̂⁺*Q̃') * Â * (Q̃*Σ̂⁺)
#M̂ = (Q̂*Σ̂⁺)' * Ĵ * (Q̂*Σ̂⁺)

G̃ = Σ̃^2   # == Q̃' * Ĝ * Q̃
Ã = Q̃' * Â * Q̃
J̃ = Q̃' * Ĵ * Q̃

function res(z, G=G̃, A=Ã, J=J̃)
    U = J - z * A - z' * A' + z'z * G
    ξ = real.( eigvals(U, G) )
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.02:1.2
z_grid = xs' .+ ys .* im

residuals = @showprogress map(res, z_grid)

λ, ev = eigen(K̂)

#sort!(λ, by=abs, rev=true)

p1 = plot(exp.(im .* (-π:0.001:π)), 
    style=:dash, aspectratio=1., leg=false, color=:blue,
    size=(450,400),
)
contour!(xs, ys, log10.(residuals .+ 1e-20), 
    colormap=:acton, linewidth=2, alpha=0.8,
    clabels=true, cbar=true,
    #levels=[0.05:0.1:0.35; 0.5:0.25:1]
    levels=[-1.5, -1.25, -1.0, -0.75, -0.5, -0.25, -0.1]
)
scatter!(λ, 
    xlabel="", ylabel="", 
    markersize=1, markerstrokewidth=1.5, 
    color=2,
    markeralpha=0.9
)
contourf!(
    xs, ys, fill(NaN, length(xs), length(ys)),
    xlims=(-1.2,1.2), ylims=(-1.2,1.2),
    colormap=:acton, linewidth=2,
    clims=(-1.6,0),
    alpha=0.8,
    rightmargin=4mm,
    xlabel=L"Re (\lambda)", ylabel=L"Im (\lambda)", 
)

scatter(angle.(λ), log.(abs.(λ)), marker_z=res.(λ))







