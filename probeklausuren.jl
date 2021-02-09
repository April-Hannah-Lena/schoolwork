using Distributions, Statistics, DataFrames

function coverage_interval(x, α)
    quant = quantile(Normal(), 1 - (α / 2))
    Cup = mean(x) + ( 5*quant / sqrt(length(x)) ) 
    Cdown = mean(x) - ( 5*quant / sqrt(length(x)) )
    return [Cdown, Cup]
end

probes = 5 .* randn(200)
i = 2
coverage = coverage_interval(probes[1:2], 0.1)

while abs( coverage[1] - coverage[2] ) > 1.25
    coverage = coverage_interval(probes[1:i], 0.1)
    #println(coverage)
    i += 1
end

i2 = 0
coverage = coverage_interval(probes, i2)

while abs( coverage[1] - coverage[2] ) > 1.15
    coverage = coverage_interval(probes, i2)
    #println(coverage)
    i2 += 0.0001
end

coverage = coverage_interval(probes[1:150], 0.2)
int = abs( coverage[1] - coverage[2] ) 

results = DataFrame(
    "a" => i,
    "b" => i2,
    "c" => int
)

println(results)
