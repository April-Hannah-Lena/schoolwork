using Plots, PlotThemes
theme(:dark)

x = [1.0]
ω = [x[1] - atan(x[1])]
k = 1

while abs(x[k] - atan(2*x[k])) > eps()
    push!(x, atan(2*x[k]))
    push!(ω, x[k] - atan(2*x[k]))
    println("$(x[k])    ", "$(ω[k])")
    k += 1
end

plot(abs.(ω), xaxis = :log10, leg=false)
θ = (x[end] - x[end-1]) / (x[end-1] - x[end-2])