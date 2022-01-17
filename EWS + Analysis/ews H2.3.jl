K = Base.checked_abs(rand(Int8)); display(K)
L = Base.checked_abs(rand(Int8))
N = Base.checked_abs(K + L); display(N)
n = Base.checked_abs(rand(1:min(K, L))); display(n)
k = Base.checked_abs(rand(0:n)); display(k)

function P(a)

    p = 0.0
    for i in 0:n
        p += (i + 1) ^ (n - i)
    end

    return [p, (a + 1) ^ (n - a) / p]
end

test = P(k); println(test)

om = [0.0, 0.0]
for l in 0:n
    global om += P(l)
end

println(om[2])