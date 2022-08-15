using Plots, ProgressMeter, Serialization

default(
    fontfamily="computer modern",
    linewidth=2, 
    framestyle=:box
)
#Plots.scalefontsizes(1.3)


types  = ["nothing", "cpu", "gpu"]
steps  = ceil.(Int, 10 .^ (1.0:3.0))
points = 4 .* ceil.(Int, 10 .^ (1.0:0.2:3.0))

times = @showprogress([
    Meta.parse(readchomp(`julia --threads=auto boxmap_benchmark.jl $t $s $p`)) 
    for t in types, s in steps, p in points
])

serialize("times_points.jls", times)


p = plot(
    points,
    [times[t, 1, :] for t in 1:length(types)],
    xaxis=("Number of points", :log),
    yaxis=("Time (s)", :log),
    title="Execution Time for Simple Map",
    lab=permutedims(["None", "CPU", "GPU"])
);
savefig(p, "times_simple.pdf")

p = plot(
    points,
    [times[t, 2, :] for t in 1:length(types)],
    xaxis=("Number of points", :log),
    yaxis=("Time (s)", :log),
    title="Execution Time for Medium Map",
    lab=permutedims(["None", "CPU", "GPU"])
);
savefig(p, "times_medium.pdf")

p = plot(
    points,
    [times[t, 3, :] for t in 1:length(types)],
    xaxis=("Number of points", :log),
    yaxis=("Time (s)", :log),
    title="Execution Time for Complex Map",
    lab=permutedims(["None", "CPU", "GPU"])
);
savefig(p, "times_complex.pdf")


steps = ceil.(Int, 10 .^ (0.6:0.1:5.0))

times = @showprogress([
    Meta.parse(readchomp(`julia --threads=auto boxmap_benchmark.jl $t $s 400`))
    for t in types, s in steps
])

serialize("times_complexity.jls", times)


p = plot(
    steps,
    [times[t, :] for t in 1:length(types)],
    xaxis=("Number of steps", :log),
    yaxis=("Time (s)", :log),
    title="Map Complexity vs Execution Time",
    lab=permutedims(["None", "CPU", "GPU"])
);
savefig(p, "times_steps.pdf")

