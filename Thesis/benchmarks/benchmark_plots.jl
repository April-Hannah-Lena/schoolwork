using Plots, Serialization

default(
    fontfamily="computer modern",
    linewidth=2, 
    framestyle=:box
)
#Plots.scalefontsizes(1.3)
    
flops(point, step, time) = point * step * ( 1 + 4 * 9 + 15 * 3 ) / time
function linreg(xs, ys)
    X = sum(xs) / length(xs)
    Y = sum(ys) / length(ys)
    m = sum((xs .- X) .* (ys .- Y)) / sum((xs .- X) .^ 2)
    b = Y - m * X
    return m, b
end

types  = ["nothing", "cpu", "gpu"]
steps  = ceil.(Int, 10 .^ (1.0:3.0))
points = 4 .* ceil.(Int, 10 .^ (1.0:0.2:3.0))
times  = deserialize("times_points.jls")


p = plot(
    points,
    [flops.(points, steps[1], times[t, 1, :]) for t in 1:length(types)],
    #size=(900,600),
    xaxis=("Number of points", :log),
    yaxis=("FLOP / s", :log),
    #title="Execution Time for Simple Map",
    #legend_title="Acceleration",
    #legend_position=:topleft,
    #lab=permutedims(["None", "CPU", "GPU"]),
    legend=false
)
savefig(p, "flops_simple_loglog.pdf")

p = plot(
    points,
    [flops.(points, steps[2], times[t, 2, :]) for t in 1:length(types)],
    #size=(900,600),
    xaxis=("Number of points", :log),
    yaxis=("FLOP / s", :log),
    #title="Execution Time for Medium Map",
    #legend_title="Acceleration",
    #legend_position=:topleft,
    #lab=permutedims(["None", "CPU", "GPU"]),
    legend=false
)
savefig(p, "flops_medium_loglog.pdf")

p = plot(
    points,
    [flops.(points, steps[3], times[t, 3, :]) for t in 1:length(types)],
    #size=(900,600),
    xaxis=("Number of points", :log),
    yaxis=("FLOP / s", :log),
    #title="Execution Time for Complex Map",
    #legend_title="Acceleration",
    #legend_position=:topleft,
    #lab=permutedims(["None", "CPU", "GPU"]),
    legend=false
)
savefig(p, "flops_complex_loglog.pdf")


steps = ceil.(Int, 10 .^ (0.6:0.1:5.0))
times = deserialize("times_complexity.jls")


p = plot(
    steps,
    [flops.(400, steps, times[t, :]) for t in 1:length(types)],
    #size=(900,600),
    xaxis=("Number of steps", :log),
    yaxis=("FLOP / s", :log),
    #title="Map Complexity vs Execution Time",
    legend_title="Acceleration",
    legend_position=:topleft,
    lab=permutedims(["None", "CPU", "GPU"])
)
savefig(p, "flops_steps_loglog.pdf")
