using LaTeXStrings, Plots

xs = 0.0001:0.0001:0.9999
S(x) = 4x*(1-x)
bbone(x) = 1
Pone(x) = 1/( 2*sqrt(1-x) )
fstar(x) = 1 / (π * sqrt( x*(1-x) ))
Pfstar(x) = fstar(x)
Kfstar(x) = (fstar ∘ S)(x)

kwargs = (legend=:topleft, ylims=(0., 10.), linewidth=2)
p1 = plot(xs, bbone, label=L"\mathbf{1}_{[0, 1]}"; kwargs...)
p2 = plot(xs, bbone, label=L"\mathcal{K} \mathbf{1}_{[0, 1]}"; kwargs...)
p3 = plot(xs, Pone, label=L"\mathcal{L} \mathbf{1}_{[0, 1]}"; kwargs...)
p4 = plot(xs, fstar, label=L"f_*"; kwargs...)
p5 = plot(xs, Kfstar, label=L"\mathcal{K} f_*"; kwargs...)
p6 = plot(xs, fstar, label=L"\mathcal{L} f_*"; kwargs...)
p = plot(p1, p2, p3, p4, p5, p6)

savefig(p, "../figures/koopman_perron_invariance_example.pdf")

N = 1_000_000
empirical_xs = rand(N)

kwargs = (bins = 0:0.05:1, normalize=:pdf, ylims=(0., 5.), leg=:topleft, fillcolor=:black, fillalpha=0.02)
q1 = histogram(empirical_xs, label="Uniform samples"; kwargs...)

map!(S, empirical_xs, empirical_xs)
q2 = histogram(empirical_xs, label="Samples mapped by S"; kwargs...)

map!(S, empirical_xs, empirical_xs)
q3 = histogram(empirical_xs, label="Samples mapped by S²"; kwargs...)

for _ in 3:10
    map!(S, empirical_xs, empirical_xs)
end
q4 = histogram(empirical_xs, label="Samples mapped by S¹⁰"; kwargs...)
q4 = plot!(xs, fstar, style=:dash, linewidth=2, color=:pink, lab=false)

q = plot(q1, q2, q3, q4)#, size=(900,300))

savefig(q, "../figures/perron_asymptotic.pdf")