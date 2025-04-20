# q/m E --> -∇ϕ
# v × B /c --> v × B, ie remove 1/c everywhere

using ForwardDiff
using StaticArrays, LinearAlgebra
using Plots, ProgressMeter

function boris(xk, vk, E, B, Δt)
    
    #xk_old = xk
    xk = xk + Δt/2 * vk

    Ek = E(xk)
    Bk = B(xk)

    #=
    Ω̂k = SA_F64[
          0     -Bk[3]  Bk[2];
         Bk[3]    0     Bk[1];
        -Bk[2]  -Bk[1]   0   ;
    ]
    Ω̂k *= Δt#/2

    vk = (I + Ω̂k) \ ( (I - Ω̂k) * vk  +  Δt * Ek )
    =#

    vk⁻ = vk + Δt/2 * Ek
    vk⁺ = vk⁻ + ( vk⁻ + vk⁻ × (Δt/2 * Bk) ) × ( Δt * Bk / (1 + norm(Δt/2 * Bk)^2) )
    vk = vk⁺ + Δt/2 * Ek

    xk = xk + Δt/2 * vk

    return xk, vk
end

function rk4(f, (x, v), Δt)
    u = SA_F64[x..., v...]

    Δt½ = Δt / 2

    k = f(u)
    du = @. k / 6

    k = f(@. u + Δt½ * k)
    du = @. du + k / 3

    k = f(@. u + Δt½ * k)
    du = @. du + k  / 3

    k = f(@. u + Δt * k)
    du = @. du + k  / 6

    u = @. u + Δt * du

    x = SA_F64[u[1], u[2], u[3]]
    v = SA_F64[u[4], u[5], u[6]]

    return x, v
end

function evolution_rule(uk, E, B)

    xk = SA_F64[uk[1], uk[2], uk[3]]
    vk = SA_F64[uk[4], uk[5], uk[6]]

    Ek = E(xk)
    Bk = B(xk)

    wk = Ek + vk × Bk

    return SA_F64[vk..., wk...]
end

ϕ(x) = x[1]^3 - x[2]^3 + x[1]^4 / 5 + x[2]^4 + x[3]^4 
E(x) = -ForwardDiff.gradient(ϕ, x)

B(x) = SA_F64[0, 0, sqrt( x[1]^2 + x[2]^2 )]
#B(x) = SA_F64[x[2] - x[3], x[1] + x[3], x[2] - x[1]] / 2

x0 = SA_F64[0, 1, 0.1]
v0 = SA_F64[0.09, 0.55, 0.3]
u0 = SA_F64[x0..., v0...]

ℇ(x, v, ϕ=ϕ) = norm(v)^2 / 2 + ϕ(x)
ℇ0 = ℇ(x0, v0)

Δt = 1e-2
T = 400_000
K = Int(T / Δt)

u_boris = NTuple{2,SVector{3,Float64}}[(x0, v0)]
u_rk4 = copy(u_boris)

u_boris_current = u_boris[end]
u_rk4_current = u_rk4[end]

ℇ_boris = [ℇ0]
ℇ_rk4 = [ℇ0]

ts = Δt:Δt:T
sample = [1:2_000; K÷2_000:K÷2_000:K-K÷2_000; K-2_000:K;]
sample_ts = ts[sample]

@showprogress for k in 1:K

    uk_boris_new = boris(u_boris_current..., E, B, Δt/2)
    uk_boris_new = boris(uk_boris_new..., E, B, Δt/2)
    uk_rk4_new = rk4(u->evolution_rule(u, E, B), u_rk4_current, Δt)

    global u_boris_current = uk_boris_new
    global u_rk4_current = uk_rk4_new

    if k in sample
        push!(u_boris, uk_boris_new)
        push!(u_rk4, uk_rk4_new)

        push!(ℇ_boris, ℇ(uk_boris_new...))
        push!(ℇ_rk4, ℇ(uk_rk4_new...))
    end
end



u_boris_matrix = reshape(reinterpret(Float64, u_boris), (3,2,:))
u_rk4_matrix = reshape(reinterpret(Float64, u_rk4), (3,2,:))

px12_boris = plot(u_boris_matrix[1, 1, 1:2_000], u_boris_matrix[2, 1, 1:2_000], line_z=sample_ts[1:2_000])
px12_rk4 = plot(u_rk4_matrix[1, 1, 1:2_000], u_rk4_matrix[2, 1, 1:2_000], line_z=sample_ts[1:2_000])

px34_boris = plot(u_boris_matrix[1, 1, length(sample)-2_000:length(sample)], u_boris_matrix[2, 1, length(sample)-2_000:length(sample)], line_z=sample_ts[length(sample)-2_000:length(sample)])
px34_rk4 = plot(u_rk4_matrix[1, 1, length(sample)-2_000:length(sample)], u_rk4_matrix[2, 1, length(sample)-2_000:length(sample)], line_z=sample_ts[length(sample)-2_000:length(sample)])

#=
px1 = plot(sample_ts, u_boris_matrix[1, 1, 2:end], lab=false)
px2 = plot(sample_ts, u_boris_matrix[2, 1, 2:end], lab=false)
px3 = plot(sample_ts, u_boris_matrix[3, 1, 2:end], lab=false)

pv1 = plot(sample_ts, u_boris_matrix[1, 2, 2:end], lab=false)
pv2 = plot(sample_ts, u_boris_matrix[2, 2, 2:end], lab=false)
pv3 = plot(sample_ts, u_boris_matrix[3, 2, 2:end], lab=false)

plot(px1, px2, px3, pv1, pv2, pv3)

scatter(
    u_rk4_matrix[1, 1, 2:end], 
    u_rk4_matrix[2, 1, 2:end], 
    u_rk4_matrix[3, 1, 2:end], 
    marker_z=sample_ts, markeralpha=0.1, markersize=1
)
=#

@views plot(sample_ts, abs.(ℇ_boris[2:end] .- ℇ0), lab="boris", title="Energy Discrepancy", yscale=:log10, alpha=0.5)
@views plot!(sample_ts, abs.(ℇ_rk4[2:end] .- ℇ0), lab="rk4", alpha=0.5)
@views plot!(sample_ts[2:end], t->Δt^2 * t, lab="t -> Δt^2 * t")