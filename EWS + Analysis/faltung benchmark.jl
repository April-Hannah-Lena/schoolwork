using FFTW, QuadGK, BenchmarkTools, Plots

function faltung_direkt(f::Function, g::Function, x)
    fg(y::Real) = f.(x.-y) .* g(y)
    return quadgk.(fg, -Inf, Inf)[1]
end

function faltung_FFT(f::Function, g::Function, x)
    f̃ = fft(f.(x))
    g̃ = fft(g.(x))
    faltung = ifft(f̃ .* g̃)
    return abs.(faltung)
end

f(x) = abs(x) < 1 ? 1 - abs(x) : 0

g(x) = abs(x) < π ? x*cos(x/2) + cos(5x/2) : 0      # irgendeine Funktion
x_range = -2π : 0.1 : 2π

@benchmark faltung_direkt($f, $g, $x_range); @show faltung_direkt(f, g, x_range)
@benchmark faltung_FFT($f, $g, $x_range); @show faltung_FFT(f, g, x_range)

p = plot(x_range, abs.(fft(g.(x_range))))



ĝ = fft(g.(x_range))
g_ = ifft(g̃)

g.(x_range) ≈ g_

function conv(f, g)
    return [f[length(f)-i+1] * g[i] for i in 1:length(f)]
end

gg = faltung_direkt(g, g, x_range)

ĝĝ = ĝ .* ĝ

g̲g̲ = abs.(ifft(ĝĝ))

println(hcat(gg, g̲g̲))
