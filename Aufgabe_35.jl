using SymPy

@syms h x                     # x und h sind symbolische Variablen
@symfuns f                    # f eine bel. Funktion
F = integrate(f(x), (x,0,h))  # F das Integral von f (von 0 bis h)

q1 = ( 5 * f((Sym(1)/2 - sqrt(Sym(15))/10) * h) + 8 * f(h/2) + 5 * f((Sym(1)/2 + sqrt(Sym(15))/10) * h) ) * h / 18                # eine Quadraturformel
series(F - q1, h, n=8)        # Taylorentwicklung
series(F - q1, h)