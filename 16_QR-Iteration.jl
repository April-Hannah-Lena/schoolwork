using LinearAlgebra, Printf

function QR_Iteration(A)
    m = size(A,1); U = I; k = 0              # Initialisierungen
    normA = norm(A)                          # Frobenius-Norm
    while norm(A[m,1:m-1]) > 5*eps()*normA   # Rückwärtsfehler noch zu groß?
        k = k + 1
        μ = eigvals(A[m-1:m,m-1:m])
        μ = μ[argmin(abs.(μ.-A[m,m]))]       # Wilkinson-Shift
        Q, R = qr(A - μ*I)                   # QR-Zerlegung
        A = R*Q + μ*I                        # RQ-Multiplikation
        U = U*Q                              # Aufsammeln der Trafos
    end
    λ = A[m,m]             # Eigenwert
    B = A[1:m-1,1:m-1]     # deflationierte Matrix
    w = A[1:m-1,m]         # Restspalte
    return λ, U, B, w, k
end;   

m = 100
A = randn(m,m)

λ, U, B, w, k = QR_Iteration(A);
println("# Schritte = ", (@sprintf "%2d" k), "; Eigenwert λ = ", λ)

function Schur(A)
    m,n = size(A)
    T = complex(zeros(m,n))
    Q = complex(Matrix{Float64}(I,m,n))
    steps = 0
    for k = m:-1:1
        λ, U, A, w, j = QR_Iteration(A)
        steps += j
        Q[:,1:k] = Q[:,1:k]*U
        T[1:k,k+1:m] = U'*T[1:k,k+1:m]
        T[1:k,k] = [w; λ]
        println("dim = ", (@sprintf "%3d" k), ": # Schritte =", (@sprintf "%2d" j))
    end
    return T, Q, steps/m
end;

@time T, Q, k = Schur(A)

println("\nMittelwert der Anzahl der Schritte    = ", (@sprintf "%.2g" k))
println("Relatives Residuum Q' A Q - T (Schur) = ", (@sprintf "%.1e" norm(Q'*A*Q-T)/norm(A)))
println("Residuum in Orthogonalität von Q      = ", (@sprintf "%.1e" norm(Q'Q-I)))