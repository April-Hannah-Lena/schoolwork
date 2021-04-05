n = rand(1:typemax(UInt8))
d = rand(Float64, n)
l = rand(Float64, n-1)
r = rand(Float64, n-1)
A = zeros(Float64, (n, n))

function bidiag!(d, l, r)
    A[1, 1] = d[1]
    for i in 2:length(d)
        A[i, i] = d[i]
        A[i, i-1] = l[i-1]
        A[i-1, i] = r[i-1]
    end
    return A
end

println("A = ", bidiag!(d, l, r))