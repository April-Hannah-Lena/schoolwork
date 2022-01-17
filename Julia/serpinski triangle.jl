using Plots, PlotThemes, LinearAlgebra
theme(:dark)

function serpinski(a, b, c, ϵ, fig)
    d1, d2, d3 = b - a, c - b, a - c
    if norm(d1) ≤ ϵ
        plot!(fig, [a[1], b[1], c[1], a[1]], [a[2], b[2], c[2], a[2]], fill=true)
    else
        r1, r2, r3 = a + d1./2, b + d2./2, c + d3./2
        serpinski(a, r1, r3, ϵ, fig)
        serpinski(r1, b, r2, ϵ, fig)
        serpinski(r3, r2, c, ϵ, fig)
    end
end
a, b, c = [0., sqrt(3)/2], [0.5, 0.], [-0.5, 0.]
fig = plot(aspect_ratio=1, leg=false)
ϵ = 1.
serpinski(a, b, c, ϵ, fig)

ϵs = [ϵ]
for i in 1:5
    push!(ϵs, ϵs[end]/3)
end

anim = @animate for e in ϵs
    fig = plot(aspect_ratio=1, leg=false)
    serpinski(a, b, c, e, fig)
end
gif(anim, fps=1)