x = collect(range(1, length=5))

function f(y)
    y^3
end

for i in x
    println("|", " "^f(i), "+")
end
println("  ", "-"^f(x[end]))