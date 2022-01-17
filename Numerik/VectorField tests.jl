using VectorField

Df(x, y) = [-x, y]
u = [Df(x, y)[1] for x in -1:0.5:1, y in -1:0.5:1]
v = [Df(x, y)[2] for x in -1:0.5:1, y in -1:0.5:1]
uv = [Df(x, y) for x in -1:0.5:1, y in -1:0.5:1]

vectorfield(-1:0.5:1, -1:0.5:1, Df)
vectorfield(-1:0.5:1, -1:0.5:1, u, v)
vectorfield(-1:0.5:1, -1:0.5:1, uv)