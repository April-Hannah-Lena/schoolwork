using GAIO

const type = Symbol(ARGS[1])
const steps = Int32(Meta.parse(ARGS[2]))
const step_size = Float32(0.1f0 / steps)
const points = Int32(Meta.parse(ARGS[3]))

# the Lorenz system
const b = 0.208186

v((x,y,z)) = (sin(y)-b*x, sin(z)-b*y, sin(x)-b*z)
f(x) = rk4_flow_map(v, x, step_size, steps)

center, radius = Float32.((0,0,0)), Int32.((5,5,5))
P = BoxPartition(Box(center, radius), Int32.((128,128,128)))
x = zeros(3)
S = P[x]

F = BoxMap(f, P, type, no_of_points=points)
W = unstable_set!(F, S)
print(@elapsed unstable_set!(F, S))

