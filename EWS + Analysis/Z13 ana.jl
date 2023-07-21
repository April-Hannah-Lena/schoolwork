using Plots, PlotlyJS, ForwardDiff, LinearAlgebra
plotlyjs()
gr()


function karte3d(f, xs, ys; kwargs...)
    f_vals = [f(x, y) for x in xs, y in ys]
    p = plot(
        getindex.(f_vals[1, :], 1), 
        getindex.(f_vals[1, :], 2), 
        getindex.(f_vals[1, :], 3), 
        leg=false, color=:red;
        kwargs...
        )

    for i in 2:length(xs)
        p = plot!(
            getindex.(f_vals[i, :], 1), 
            getindex.(f_vals[i, :], 2), 
            getindex.(f_vals[i, :], 3), 
            leg=false, color=:red;
            kwargs...
            )
    end
    for i in 1:length(ys)
        p = plot!(
            getindex.(f_vals[:, i], 1), 
            getindex.(f_vals[:, i], 2), 
            getindex.(f_vals[:, i], 3), 
            leg=false, color=:red;
            kwargs...
            )
    end

    return p
end

function projektion!(f, xs, ys; kwargs...)   
    f_vals = [f(x, y) for x in xs, y in ys] 
    f_vals_center = val_center.(f_vals, 0.5)
    for i in 1:length(xs)
        p = plot!(
            getindex.(f_vals_center[i, :], 1), 
            getindex.(f_vals_center[i, :], 2), 
            getindex.(f_vals_center[i, :], 3), 
            leg=false, color=:blue;
            kwargs...
            )
    end
    for i in 1:length(ys)
        p = plot!(
            getindex.(f_vals_center[:, i], 1), 
            getindex.(f_vals_center[:, i], 2), 
            getindex.(f_vals_center[:, i], 3), 
            leg=false, color=:blue;
            kwargs...
            )
    end

    return p
end

function val_center(val, scale=1.)
    n = scale / norm((val[1], val[2]))
    val .* (n, n, 1)
end

function karte3d!(f, xs, ys; kwargs...)
    f_vals = [f(x, y) for x in xs, y in ys]
    p = nothing
    for i in 1:length(xs)
        p = plot!(
            getindex.(f_vals[i, :], 1), 
            getindex.(f_vals[i, :], 2), 
            getindex.(f_vals[i, :], 3), 
            leg=false, color=:red;
            kwargs...
            )
    end
    for i in 1:length(ys)
        p = plot!(
            getindex.(f_vals[:, i], 1), 
            getindex.(f_vals[:, i], 2), 
            getindex.(f_vals[:, i], 3), 
            leg=false, color=:red;
            kwargs...
            )
    end

    return p
end

function normal!(f, x, y; scalefactor=1, kwargs...)
    n = zeros(2, 3)
    n[1, :] = f(x, y)
    A = ForwardDiff.jacobian(z -> f(z...), [x, y])
    n[2, :] = cross(A[:, 1], A[:, 2]) |> normalize |> x -> x .* scalefactor
    n[2, :] = n[1, :] .+ n[2, :]
    p = plot!(n[:, 1], n[:, 2], n[:, 3]; kwargs...)
    return p
end

f(x, y) = (
    (1+y*cos(x/2))*cos(x),
    (1+y*cos(x/2))*sin(x),
    y*sin(x/2) + 0.1*cos(3x+π/6)
)

xs, ys = -2π:π/20:2π, -0.2:0.05:0.2

p = karte3d(f, xs, ys; 
        camera=(30, 40), linealpha=0.7, lims=(-1.5, 1.5))
        #normal!(f, 0, 0, scalefactor=-1)

ρ(θ, z) = (0.5*cos(θ), 0.5*sin(θ), 4z)
p = karte3d!(ρ, xs, ys, color=:orange)

λs = [ones(10); 1:-1/120:0.0; 0.0.*ones(20)]
animf = @animate for λ in λs
    fλ(x, y) = (1 - λ) .* val_center(f(x, y), 0.5) .+ λ .* f(x, y)
    p = karte3d(ρ, xs, ys; 
        camera=(
            round(Int, 20+0.8*rad2deg(π*λ)), 
            round(Int, 20+0.3*rad2deg(π*λ/2))
        ), 
        linealpha=0.25, 
        lims=(-1.2, 1.2)
    )
    p = karte3d!(fλ, xs, ys, color=:blue)
end
g = gif(animf, "../../Desktop/moebius_band_tat_3.gif", fps=20)

p = projektion!(f, xs, ys)

animf = @animate for i in -2π:0.05:2π
    karte3d(f, -2π:0.1:2π, -0.5:0.02:0.5; 
            camera=(30, 70), linealpha=0.7, lims=(-1.5, 1.5))
    normal!(f, i, 0.0, scalefactor=-1, lims=(-1.5, 1.5))
end
gif(animf, fps=20)

g(r, θ) = [r*cos(θ),
           r*sin(θ),
           θ]

karte3d(g, 0:0.1:1, 0:0.05:3π; 
        linealpha=0.7, camera=(30, 50))

h(ϕ, θ) = [cos(ϕ)*sin(θ),
           sin(ϕ)*sin(θ),
           cos(θ)]

karte3d(h, -π:0.1:π, 0:0.1:π;
        linealpha=0.7, camera=(10, 40))

l(s, t) = [(4+cos(t))*cos(s), 
           (4+cos(t))*sin(s), 
           sin(t)]

karte3d(l, 0:0.1:2*π, 0:0.1:2*π;
        linealpha=0.7, camera=(10, 55), zlims=(-2, 2))
normal!(l, 3*π/2, π/2, scalefactor=1)