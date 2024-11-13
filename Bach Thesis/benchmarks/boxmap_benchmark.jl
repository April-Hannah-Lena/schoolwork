using GAIO, Serialization

const type = Symbol(ARGS[1])
const steps = Int32(Meta.parse(ARGS[2]))
const step_size = Float32(0.1f0 / steps)
const points = Int32(Meta.parse(ARGS[3]))

# the Lorenz system
const σ, ρ, β = 10.0f0, 28.0f0, 0.4f0
v((x,y,z)) = (σ*(y-x), ρ*x-y-x*z, x*y-β*z)
f(x) = rk4_flow_map(v, x, step_size, steps)

center, radius = Float32.((0,0,25)), Float32.((30,30,30))
P = BoxPartition(Box(center, radius), Int32.((128,128,128)))
F = BoxMap(f, P, type, no_of_points=points)

x = (sqrt(β*(ρ-1)), sqrt(β*(ρ-1)), ρ-1)         # equilibrium
S = BoxSet(P, deserialize("indices.jls"))
W = F(S)
print(@elapsed F(S))
