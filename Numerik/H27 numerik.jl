using Polynomials, Printf, DataFrames
using Pipe: @pipe

x = 0.923


n = 31
c = @pipe ChebyshevT([zeros(n); 1]) |> convert(Polynomial, _) |> coeffs(_)

h = c[n+1]
for i in n:-1:1
    h = h*x + c[i]
end


n̂ = 57
c = begin @pipe ChebyshevT([zeros(n̂); 1]) |> 
                convert(Polynomial, _) |> 
                coeffs(_)
end

ĥ = c[n̂+1]
for i in n̂:-1:1
    ĥ = ĥ*x + c[i]
end

T = zeros(n̂+1); T[2] = x
for i in 2:n̂
    T[i+1] = 2*x*T[i] - T[i-1]
end

C = ChebyshevT([zeros(n); 1])(x)
Ĉ = ChebyshevT([zeros(n̂); 1])(x)


@printf "%-15s %-15s %-10s %-15s \n" "n" n "|" n̂
@printf "%-15s %-15s %-10s %-15s \n" "-----" "-----" "|" "-----"
@printf "%-15s %-15.5f %-10s %-15.5f \n" "Horner" h "|" ĥ
@printf "%-15s %-15.5f %-10s %-15.5f \n" "rekursiv" T[32] "|" T[58]
@printf "%-15s %-15.5f %-10s %-15.5f \n" "korrekt" C "|" Ĉ

da = Dict("n" => [31, 57], 
      "korrekt" => [C, Ĉ], 
      "Horner" => [h, ĥ], 
      "Horner fehler" => [h - C, ĥ - Ĉ], 
      "rekursiv" => [T[32], T[58]], 
      "rekursiv fehler" => [T[32] - C, T[57] - Ĉ]
)

df = DataFrame("n" => [31, 57], 
               "korrekt" => [C, Ĉ], 
               "Horner" => [h, ĥ], 
               "Horner fehler" => [h - C, ĥ - Ĉ], 
               "rekursiv" => [T[32], T[58]], 
               "rekursiv fehler" => [T[32] - C, T[57] - Ĉ]
              )

df # DataFrame looks best in the REPL


#println("n                                31   |   57")
#println("==========================================================")
#println("Horner             $h   |   $ĥ")
#println("rekursiv        $(T[32])   |   $(T[58])")
#println("korrekt          $C   |    $Ĉ")