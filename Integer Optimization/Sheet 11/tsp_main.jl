using TSPLIB
include("tsp_helper.jl")

# load custom TSP solver functions
include("tsp_xxx.jl")  # TODO: replace with the code file containing your solver function

# read one of the preloaded TSPLIB instances
tsp = readTSPLIB(:ulysses22)

# print small summary of instance characteristics
print("Load instance $(tsp.name) on $(tsp.dimension) nodes. ")
println("Weight matrix is of size ", size(tsp.weights))

# solve and plot solution
@time solution = solve_tsp_xxx(tsp)  # TODO: replace with your solver function
plot_tsp(tsp; solution=solution)
