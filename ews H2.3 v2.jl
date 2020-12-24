K = Base.checked_abs(rand(Int8)); println("K = ", K)
L = Base.checked_abs(rand(Int8)); println("L = ", L)
N = Int32(K) + Int32(L); println("N = K + L = ", N)
n = rand(1:min(K, L)); println("n = ", n)
k = rand(0:n); println("k = ", k)

function P(a)
    binomial(BigInt(K), a) * binomial(BigInt(N - K), n - a) / binomial(BigInt(N), n)
end

omega = 0.0
for i in 0:n
    global omega += P(i)
end

println([Float64(P(k), RoundUp), Float64(omega, RoundUp)])