f(x) = x^3

println(" x  | x^3 ")
for i in 0.0:0.5:2
	println(i, " | ", f(i))
end

using Pkg
Pkg.update()