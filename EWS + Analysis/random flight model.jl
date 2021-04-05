using RCall, GeometryBasics, Plots, PlotThemes
theme(:dark)

function randomwalk(n)
    ϕ = 2π .* rand(n)
    point = Point2(cos(ϕ[1]), sin(ϕ[1]))
    points = [point]
    for i in 2:n
        point += Point2(cos(ϕ[i]), sin(ϕ[i]))
        points = push!(points, point)
    end

    return points
end

p = R"uniroot(function(p) pbinom(25, 30, p, lower.tail=FALSE)-0.9, lower=0, upper=1)" |> 
    rcopy |> 
    x -> x[:root]
function r(n)
    r = R"qchisq($p, 2)" |> rcopy
    r = sqrt(n * r / 2)
end

function circle(center, r)
    c = @. Point2(r*cos(0:0.1:2π+0.1), r*sin(0:0.1:2π+0.1))
    c = c .+ center
end


randomwalks1 = [randomwalk(100) for n in 1:30]
randomwalks2 = [randomwalk(100) for n in 1:30]
randomwalks3 = [randomwalk(100) for n in 1:30]
randomwalks4 = [randomwalk(100) for n in 1:30]

itr = vcat(1:100, ones(Int, 19).*100)
anim = @animate for j in itr
    p1 = plot(circle(Point2(0), r(100)), 
              fill=true, fillalpha=0.2, leg=false, 
              xlims=(-20, 20), ylims=(-20, 20))
    for k in 1:30
        p1 = plot!(getindex(randomwalks1[k], 1:j))
    end
    p2 = plot(circle(Point2(0), r(100)), 
              fill=true, fillalpha=0.2, leg=false, 
              xlims=(-20, 20), ylims=(-20, 20))
    for k in 1:30
        p2 = scatter!(getindex(randomwalks1[k], j))
    end
    p3 = plot(circle(Point2(0), r(100)), 
              fill=true, fillalpha=0.2, leg=false, 
              xlims=(-20, 20), ylims=(-20, 20))
    for k in 1:30
        p3 = plot!(getindex(randomwalks2[k], 1:j))
    end
    p4 = plot(circle(Point2(0), r(100)), 
              fill=true, fillalpha=0.2, leg=false, 
              xlims=(-20, 20), ylims=(-20, 20))
    for k in 1:30
        p4 = scatter!(getindex(randomwalks2[k], j))
    end

    plot(p1, p2, p3, p4, layout=(2, 2))
end
gif(anim, fps=30)