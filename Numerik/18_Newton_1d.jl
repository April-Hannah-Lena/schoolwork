f(x) = (x-0.2)*(x+0.2)
Df(x) = (x-0.2)+(x+0.2)

k, x = 0, 0.1
while abs(f(x)) > eps()
    h = -f(x)/Df(x)
    x = x + h
    k += 1
end
x, k
