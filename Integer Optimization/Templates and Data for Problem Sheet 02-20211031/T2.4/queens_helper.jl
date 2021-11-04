function print_pattern(pattern::Matrix{Int}, unicode=false)
    n = size(pattern, 1)  # assume quadratic
    max_digits = Int(floor(log(10, n+1)))
    sep_row = ("+" * '\u2014'^3)^n * "+"
    queen_chars = unicode ? "\u265B\u2009" : "Q "
    
    println(" "^(max_digits+3) * join(map(i -> lpad(i,2," "), 1:n), "  "))
    println(" "^(max_digits+2) * sep_row)
    for i=1:n
        row_list = [pattern[i,j] == 1 ? "| " * queen_chars : "|   " for j=1:n]
        println(lpad(i,max_digits+1," ") * " " * join(row_list) * "|")
        println(" "^(max_digits+2) * sep_row)
    end
end