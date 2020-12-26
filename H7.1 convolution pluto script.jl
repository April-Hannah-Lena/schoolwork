### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 12ccf410-47b0-11eb-1d55-5f80a8e460f5
using QuadGK, Plots, PlotThemes, PlutoUI

# ╔═╡ 62e122f2-47b0-11eb-09fe-e3bb9e6bc41c
function faltung(f::Function, g::Function, x)
    return quadgk(y -> f(x-y)*g(y), -Inf, -0.5, 0, Inf, rtol=sqrt(eps()))[1]
end

# ╔═╡ cec8ed30-47b1-11eb-3883-d96e9c8ff011
function modified_faltung(f::Function, g::Function, x, shift)
    f(x) == 0 || g(x - shift) == 0 ? 0.0 : faltung(f, g, x)
end

# ╔═╡ 61bcc730-47b0-11eb-0572-af91e426bf3f
function χ_gen(x)
    if abs(x) <= 1
        1
    elseif 1 < abs(x) <= 2
        2 - abs(x)
    else
        0
    end
end

# ╔═╡ d70c40a0-47b1-11eb-2960-6b7c808ec0ab
norm, err = quadgk(χ_gen, -2, 2)

# ╔═╡ d70da030-47b1-11eb-394f-e36c01fb13ea
χ(ϵ, x) = χ_gen(x / ϵ) / (ϵ * norm)

# ╔═╡ 8bdb66c0-47b0-11eb-035e-81fbc430f70c
f(x) = abs(x) <= π ? x * cos(x/2) + 0.5 * cos(5x/2) : 0

# ╔═╡ a10c0db0-47b0-11eb-362f-13de0bf9bd52
x_range = -5π/4:0.1:5π/4

# ╔═╡ ec8b55b0-47b1-11eb-1bda-17bff80e7486
@bind ϵ Slider(-3.7:0.01:2.0, show_value=true, default=2.0)

# ╔═╡ 329d1170-47b1-11eb-18d0-4d6a71f85c64
begin
	plot(x_range, f.(x_range), ylims=(-π/2, π/2), label="f", leg=:bottomright)
	plot!(x_range, z -> χ.(exp(ϵ), z), label="χ")
	plot!(x_range, faltung.(f, z -> χ.(exp(ϵ), z), x_range), label="faltung")
end

# ╔═╡ a70263e0-47b0-11eb-36d7-bbf5ab96a951
@bind x Slider(x_range, show_value=true, default=0.0)

# ╔═╡ e3591c20-47b6-11eb-0aef-57f0bd8d9c0f
@bind ϵ2 Slider(-3.7:0.01:2.0, show_value=true, default=2.0)

# ╔═╡ 6b589700-47b6-11eb-0434-9518c2a16831
begin
	plot(x_range, f.(x_range), label="f", ylims=(-π/2, π/2), leg=:bottomright)
	plot!(x_range, z -> χ.(exp(ϵ2), z .- x), label="χ")
	plot!(x_range, modified_faltung.(f, z -> χ.(exp(ϵ2), z), x_range, x), label="lokalisierte faltung")
end

# ╔═╡ Cell order:
# ╠═12ccf410-47b0-11eb-1d55-5f80a8e460f5
# ╠═62e122f2-47b0-11eb-09fe-e3bb9e6bc41c
# ╠═cec8ed30-47b1-11eb-3883-d96e9c8ff011
# ╠═61bcc730-47b0-11eb-0572-af91e426bf3f
# ╠═d70c40a0-47b1-11eb-2960-6b7c808ec0ab
# ╠═d70da030-47b1-11eb-394f-e36c01fb13ea
# ╠═8bdb66c0-47b0-11eb-035e-81fbc430f70c
# ╠═a10c0db0-47b0-11eb-362f-13de0bf9bd52
# ╠═ec8b55b0-47b1-11eb-1bda-17bff80e7486
# ╠═329d1170-47b1-11eb-18d0-4d6a71f85c64
# ╠═a70263e0-47b0-11eb-36d7-bbf5ab96a951
# ╠═e3591c20-47b6-11eb-0aef-57f0bd8d9c0f
# ╠═6b589700-47b6-11eb-0434-9518c2a16831