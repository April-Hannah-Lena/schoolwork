using Plots
using PlotThemes
theme(:dark)

function f(x)
    x ^ 2 / 2 ^ (x + 1)
end

r = 2.0:2.0:400
fr = []
sum_fr = [0.0]
for i in r 
    push!(fr, f(i))
    push!(sum_fr, sum_fr[end] + f(i))
end
popfirst!(sum_fr)

p = plot(r, fr, xscale=:log10)
p = plot!(p, r, sum_fr)
display(p)