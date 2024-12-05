using Chemfiles, ChemfilesViewer, BioStructures
using LinearAlgebra, Statistics, Clustering
using ProgressMeter, DataFrames
using GLMakie, BioMakie
const atoms = BioStructures.atoms

# data -------------------------------------------------------

mol = read("pentapeptide-impl-solv.pdb", PDBFormat)
chn = mol[1]["X"]

n_datasets = 25
n_timesteps = 5001 # each dataset has 5001 time steps
subsample = 50
lag = 10
timesteps = 1 : subsample : n_timesteps - lag + 1
n_timesteps_used = length(timesteps)

initial_data = zeros(3, 94, n_timesteps_used, n_datasets)
later_data = similar(initial_data)

for n in 1:n_datasets
    trajectory = Trajectory("./penta_simulations/pentapeptide-$(n-1)-500ns-impl-solv.xtc")
    for (m, time) in enumerate(timesteps)
        frame = read_step(trajectory, time)
        pos = positions(frame)
        initial_data[:, :, m, n] .= pos
        
        frame = read_step(trajectory, time + lag)
        pos = positions(frame)
        later_data[:, :, m, n] .= pos
    end
end

X = reshape(initial_data, (3*94, n_timesteps_used*n_datasets))
Y = reshape(later_data, (3*94, n_timesteps_used*n_datasets))

# kernel edmd -------------------------------------------------------

k(x, y, c=0.01) = exp(-norm(x - y)^2 / c)

meanX = mean(X, dims=2)
varX = mean(x->norm(x - meanX)^2, eachcol(X))

Ĝ = @showprogress [k(xj, xk, 2varX) for xj in eachcol(X), xk in eachcol(X)]
Â = @showprogress [k(yj, xk, 2varX) for yj in eachcol(Y), xk in eachcol(X)]
Ĵ = @showprogress [k(yj, yk, 2varX) for yj in eachcol(Y), yk in eachcol(Y)]

σ, Q = eigen(Ĝ)
r = 100#sum(σ .> 1e-4)

Σ̂ = Diagonal( sqrt.(σ[end-r+1:end]) )
Q̂ = Q[:, end-r+1:end]

Σ̂⁺ = inv(Σ̂)
K̂ = (Σ̂⁺*Q̂') * Â * (Q̂*Σ̂⁺)
M̂ = (Q̂*Σ̂⁺)' * Ĵ * (Q̂*Σ̂⁺)

#=
function res(z, G=I(r), A=K̂, J=M̂)
    U = J - z' * A - z * A' + z'z * G
    ξ = real.( eigvals(U, G) )
    return ξ[1] < 0 ? 0 : sqrt(ξ[1])
end

xs = ys = -1.2:0.02:1.2
z_grid = xs' .+ ys .* im

residuals = @showprogress map(res, z_grid)

p1 = plot(exp.(im .* (-π:0.001:π)), 
    style=:dash, aspectratio=1., leg=false, color=:blue,
    size=(400,400)
)
scatter!(λ, 
    marker=:+, 
    xlabel="", ylabel="", 
    markersize=5, markerstrokewidth=1.5, 
    color=2
)
contour!(xs, ys, residuals, 
    colormap=:acton, linewidth=2,
    xlims=(-1.2,1.2), ylims=(-1.2,1.2),
    clabels=true, cbar=false,
    levels=[0.05:0.1:0.35; 0.5:0.25:1],
    alpha=0.8
)
=#

λ, ev = eigen(K̂)

# k-medoids on eigenvectors -------------------------------------------------------

ṽ = real.(Q̂*Σ̂*ev)
v = ṽ[:, end-3:end-1]'
dists = [norm(x - y) for x in eachcol(v), y in eachcol(v)]

n_medoids = 4
clusters = kmedoids(dists, n_medoids)
medoid_indices = clusters.medoids

medoids = X[:, medoid_indices]
medoids = reshape(medoids, (3, 94, 4))

# plot mdeoid -------------------------------------------------------

which = 1 #2, 3, ..., n_mdeoids
for resid in chn
    for ato in resid
        id = ato.serial
        ato.coords .= medoids[:, id, which]
    end
end

fig = Figure();
plotstruc!(fig, mol, markerscale=0.5)
