n, m = 100, 5000
A = rand(n, m)
sz = size(A)
display(A)

a = A[1:sz[1]-1, 1]
#println("a = ", a)
b = A[1:sz[1]-1, sz[2]]
#println("b = ", b)
c = A[sz[1], 1:sz[2]]
#println("c = ", c)
B = A[1:sz[1]-1, 2:sz[2]-1]
#display(B)

A_fixed = zeros(Float64, sz[1], sz[2])
#display(A_fixed)
A_fixed[1:length(a), 1] = a;
A_fixed[1:length(b), sz[2]] = b;
A_fixed[sz[1], 1:length(c)] = c;
A_fixed[1:sz[1]-1, 2:sz[2]-1] = B;
display(A_fixed)

println("\n\n")
println(A == A_fixed ? "Success! You achieved the same thing as before" : 
        "error - not the same")