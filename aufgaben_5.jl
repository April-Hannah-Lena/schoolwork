using Plots, PlotThemes, LinearAlgebra
theme(:dark)

const A, fakt = [0 -1; 1 0], sqrt(3)/6
function koch(p, q, ϵ, fig)
    global A, fakt
    d = q - p
    r₁, r₃ = p + d./3, p + d.*2/3
    r₂ = p + d./2 + A*d*fakt
    print(norm(d))
    
    if norm(d) ≤ ϵ
        plot!(fig, [p[1], q[1]], [p[2], q[2]])
    else
        koch(p, r₁, ϵ, fig)
        koch(r₁, r₂, ϵ, fig)
        koch(r₂, r₃, ϵ, fig)
        koch(r₃, q, ϵ, fig)
    end
end

fig = plot(aspect_ratio=1, leg=false)
p = [0., 0.]; q = [1., 0.]
ϵ = 0.5
koch(p, q, ϵ, fig)

ϵs = [ϵ]
for i in 1:4
    push!(ϵs, ϵs[end]/3)
end

p₁, p₂, p₃ = [-0.5, 0.], [0., sqrt(3)/2], [0.5, 0.]
anim = @animate for e in ϵs
    fig = plot(xlims=(-0.75, 0.75), ylims=(-0.4, 1.), leg=false)
    koch(p₁, p₂, e, fig)
    koch(p₂, p₃, e, fig)
    koch(p₃, p₁, e, fig)
end
gif(anim, fps=1)