using Javis, Animations, Colors

function xreflect(point)
    return Point(-point[1], point[2])
end

function mid(point1, point2)
    return Point(
        (point1[1] + point2[1]) / 2,
        (point1[2] + point2[2]) / 2
    )
end

function ground(args...)
    background("black")
    sethue("white")
end

function drawgridlines(video, xticks, yticks, padding; color="white")
    h, w = video.height, video.width
    w2, w4 = w / 2 - padding, w / 4
    h2 = h - 2 * padding
    origin(Point(w / 2, h - padding))
    sethue(color)

    line(Point(-w4, 0.0), Point(-w4, -h2), :stroke)
    line(Point( w4, 0.0), Point( w4, -h2), :stroke)
    line(Point(-w2, 0.0), Point(-padding, 0.0), :stroke)
    line(Point( w2, 0.0), Point( padding, 0.0), :stroke)

    fontsize(12)
    l = (w4 - padding) / length(xticks)
    padding4 = padding / 4
    for (i, x) in enumerate(xticks)
        text( "$x", Point( w4 + i * l, padding4), valign=:top, halign=:center)
        text("-$x", Point( w4 - i * l, padding4), valign=:top, halign=:center)
        text( "$x", Point(-w4 + i * l, padding4), valign=:top, halign=:center)
        text("-$x", Point(-w4 - i * l, padding4), valign=:top, halign=:center)
    end
    l = h2 / length(yticks)
    for (i, y) in enumerate(yticks)
        text("$y", Point( w4 - padding4, - i * l), valign=:middle, halign=:right)
        text("$y", Point(-w4 - padding4, - i * l), valign=:middle, halign=:right)
    end

    return nothing
end

function drawgridlines_symmetric(video, xticks, yticks, padding)
    h, w = video.height, video.width
    w2, h2 = w / 2 - padding, h / 2 - padding
    w4 = w / 4
    
    line(Point(-w4, -h2), Point(-w4, h2), :stroke)
    line(Point( w4, -h2), Point( w4, h2), :stroke)
    line(Point(-w2, 0.0), Point(-padding, 0.0), :stroke)
    line(Point(padding, 0.0), Point(w2, 0.0), :stroke)
    
    fontsize(8)
    l = (w / 4 - padding) / length(xticks)
    for (i, t) in enumerate(xticks)
        text( "$t", Point( w4 + i*l, padding))
        text("-$t", Point( w4 - i*l, padding))
        text( "$t", Point(-w4 + i*l, padding))
        text("-$t", Point(-w4 - i*l, padding))
    end
    l = h2 / length(xticks)
    for (i, t) in enumerate(yticks)
        text( "$t", Point( w4 - padding, -i*l))
        text("-$t", Point( w4 - padding,  i*l))
        text( "$t", Point(-w4 - padding, -i*l))
        text("-$t", Point(-w4 - padding,  i*l))
    end

    return nothing
end

function math2pixel(video, point, xmax, ymax, padding)
    h2, w4 = video.height - padding, video.width / 4
    #origin(Point(3 * w4, h2))
    return Point(
        point[1] * (w4 - padding) / xmax, 
        - point[2] * (h2 - padding) / ymax
    )
end

function drawgraph(video, trafo, xmax, ymax, padding; delta_x=0.01, color=colorant"cyan")
    origin(Point(video.width * 3 / 4, video.height - padding))
    sethue(color)

    pixelset = map(-xmax:delta_x:xmax) do x
        math2pixel(video, Point(x, trafo(x)), xmax, ymax, padding)
    end
    old_pixel = pixelset[1]
    for pixel in pixelset
        line(old_pixel, pixel, :stroke)
        old_pixel = pixel
    end
    #circle.(pixelset, 1.0, :fill)
    return nothing
end

function levelset(trafo, t, xmax; delta_x=0.01)
    filter(x -> (t < trafo(x)), -xmax:delta_x:xmax)
end

function drawlevelset(video, set, t, xmax, ymax, padding; color="yellow")
    origin(Point(video.width * 3 / 4, video.height - padding))
    sethue(color)

    pixelset = map(set) do x
        math2pixel(video, Point(x, t), xmax, ymax, padding)
    end
    circle.(pixelset, 1.0, :fill)
    return nothing
end

function rearrangedsetmax(set; delta_x=0.01)
    return length(set) * delta_x / 2
end

function drawrearrangement(video, set, rpoints, t, xmax, ymax, padding; delta_x=0.01, color="yellow")
    set == Float64[] && return nothing
    origin(Point(video.width / 4, video.height - padding))
    sethue(color)

    w4 = video.width / 4
    h2 = video.height - 2 * padding
    delta_pixel = delta_x * (w4 - padding) / xmax
    l2 = length(set) / 2

    p1 = Point(-delta_pixel * l2, -t * h2 / ymax)
    p2 = Point( delta_pixel * l2, -t * h2 / ymax)

    push!(rpoints, p2)
    line(p1, p2, :stroke)
    return nothing
end

function drawrpoints(video, rpoints, xmax, ymax, padding; color="yellow")
    rpoints == Point[] && return nothing
    origin(Point(video.width / 4, video.height - padding))
    sethue(color)

    pixelset = vcat(rpoints, reverse(xreflect.(rpoints)))
    old_pixel = pixelset[1]
    line(
        Point(old_pixel[1], 0.0), 
        math2pixel(video, Point(4.0, 0.0), xmax, ymax, padding),
        :stroke
    )
    line(
        Point((xreflect(old_pixel))[1], 0.0), 
        math2pixel(video, Point(-4.0, 0.0), xmax, ymax, padding),
        :stroke
    )
    for pixel in pixelset
        line(old_pixel, pixel, :stroke)
        old_pixel = pixel
    end
    return nothing
end

function drawcircle(video, x, set, t, points, xmax, ymax, padding; color=colorant"red", delta_x=0.01)
    origin(Point(video.width / 4, video.height - padding))
    sethue(color)

    if abs(x) < rearrangedsetmax(set; delta_x)
        push!(
            points, 
            math2pixel(video, Point(x, t), xmax, ymax, padding)
        )
        circle.(points, 1.0, :fill)
        return nothing
    else
        circle.(points, 1.0, :fill)
        return nothing
    end
end




function trafo(x)
    abs(x) < float(pi) && return 3 * sin(x)^2 * exp(x / 4)
    return 0.0
end

xmax, ymax = 4.0, 6.0
padding = 50
x = 1.0
t = 0.5
points, rpoints = Point[], Point[]

vid = Video(1500, 500)
Background(1:120, ground)
grid = Object((args...) -> drawgridlines(args[1], 1:xmax, 1:ymax, padding))
graph = Object((args...) -> drawgraph(args[1], trafo, xmax, ymax, padding))
drawset = Object((args...; t) -> drawlevelset(
    args[1], levelset(trafo, t, xmax), t, xmax, ymax, padding
    )
)
drawset2 = Object((args...; t) -> drawrearrangement(
    args[1], levelset(trafo, t, xmax), rpoints, t, xmax, ymax, padding
    )
)
#circ = Object((args...; t) -> drawcircle(
#    args[1], x, levelset(trafo, t, xmax), t, points, xmax, ymax, padding
#    )
#)

act!(drawset, Action(1:120, change(:t, 0.0 => 6.0)))
act!(drawset2, Action(1:120, change(:t, 0.0 => 6.0)))
#act!(circ, Action(1:120, change(:t, 0.0 => 3.0)))

rgraph = Object((args...) -> drawrpoints(args[1], rpoints, xmax, ymax, padding))

render(vid, pathname="C:\\Users\\april\\Desktop\\vid.gif", framerate=15
)
#, rescale_factor=0.8)

