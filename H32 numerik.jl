using Plots, PlotThemes
theme(:dark)

H = [x -> (1-x)^2 * (1+x), 
     x -> x * (1-x)^2, 
     x -> x^2 * (2-x), 
     x -> x^2 * (x-1)
    ]

f = [2.0, 1.0, -2.0, 0.5]

function hermite(f)
    p(x) = sum(f[i]*H[i](x) for i in 1:length(f))
    return p
end

plot(-1:0.1:2, hermite(f))
scatter!([0, 1], [2, -2])