using ProgressMeter, Serialization


types  = ["nothing", "cpu", "gpu"]
steps  = ceil.(Int, 10 .^ (1.0:3.0))
points = 4 .* ceil.(Int, 10 .^ (1.0:0.2:3.0))

times = @showprogress([
    Meta.parse(readchomp(`julia --threads=auto boxmap_benchmark.jl $t $s $p`)) 
    for t in types, s in steps, p in points
])

serialize("times_points.jls", times)


steps = ceil.(Int, 10 .^ (0.6:0.1:5.0))

times = @showprogress([
    Meta.parse(readchomp(`julia --threads=auto boxmap_benchmark.jl $t $s 400`))
    for t in types, s in steps
])

serialize("times_complexity.jls", times)
