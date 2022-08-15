using Plots, Serialization

default(
    fontfamily="computer modern",
    linewidth=2, 
    framestyle=:box
)
#Plots.scalefontsizes(1.3)

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
    [times[t, 1, :] for t in 1:length(types)],
    #size=(900,600),
    xaxis=("Number of points", :log),
    yaxis=("Time (s)", :log),
    #title="Execution Time for Simple Map",
    legend_title="Acceleration",
    legend_position=:topleft,
    lab=permutedims(["None", "CPU", "GPU"])
)
savefig(p, "times_simple_loglog.pdf")

p = plot(
    points,
    [times[t, 2, :] for t in 1:length(types)],
    #size=(900,600),
    xaxis=("Number of points", :log),
    yaxis=("Time (s)", :log),
    #title="Execution Time for Medium Map",
    legend_title="Acceleration",
    legend_position=:topleft,
    lab=permutedims(["None", "CPU", "GPU"])
)
savefig(p, "times_medium_loglog.pdf")

p = plot(
    points,
    [times[t, 3, :] for t in 1:length(types)],
    #size=(900,600),
    xaxis=("Number of points", :log),
    yaxis=("Time (s)", :log),
    #title="Execution Time for Complex Map",
    legend_title="Acceleration",
    legend_position=:topleft,
    lab=permutedims(["None", "CPU", "GPU"])
)
savefig(p, "times_complex_loglog.pdf")


steps = ceil.(Int, 10 .^ (0.6:0.1:5.0))
times = deserialize("times_complexity.jls")


p = plot(
    steps,
    [times[t, :] for t in 1:length(types)],
    #size=(900,600),
    xaxis=("Number of steps", :log),
    yaxis=("Time (s)", :log),
    #title="Map Complexity vs Execution Time",
    legend_title="Acceleration",
    legend_position=:topleft,
    lab=permutedims(["None", "CPU", "GPU"])
)
savefig(p, "times_steps_loglog.pdf")
