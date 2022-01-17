using LinearAlgebra

m, n = rand(2:20), rand(1:m-1)              # initialize
A_gen = rand(m, m); A_gen = A_gen'A_gen     # ----"-----

A = [A_gen[i, j] for i in 1:m, j in 1:n]    # generate input
x = rand(m)                                 # ------"-------

F = qr(A)
q = [F.R; zeros(m-n, n)] \ (F.Q' * x)
# QR does not save zero rows to increase efficiency, 
# so they must be added back 
