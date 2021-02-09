import sympy as sp
sp.init_printing(use_unicode=True)

x = sp.Symbol('x')
h = sp.Symbol('h')
f = sp.Function('f')

F = sp.integrate(f(x), (x, 0, h))
q1 = ( 5 * f((sp.Symbol('1')/2 - sp.sqrt(sp.Symbol('15'))/10) * h) + 8 * f(h/2) + 5 * f((sp.Symbol('1')/2 + sp.sqrt(sp.Symbol('15'))/10) * h) ) * h / 18

sp.series(F - q1, x=h, n=8)
sp.Order(sp.series(F - q1, x=h, n=8))