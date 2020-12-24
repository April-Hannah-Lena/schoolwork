using Plots
using PlotThemes
theme(:dark)

function f(N, T)
    if N == 1
        return T
    end

    if 0 <= T <= 1/3
        return 0.5 * f(N - 1, 3T)
    elseif 1/3 < T < 2/3
        return 0.5
    elseif 2/3 <= T <= 1
        return 0.5 * (1.0 + f(N - 1, 3 * T - 2))
    else
        return 0.0
    end
end

#display(plot(t -> f(6, t), xlims=(0, 1)))
anim = @animate for n in 1:15
    plot(t -> f(n, t), xlims=(0, 1), ylims=(0, 1), leg=false)
end
gif(anim, "H3,4.gif", fps = 5)
