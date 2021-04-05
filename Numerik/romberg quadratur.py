import numpy as np

def T(f, a, b, h):
    I = 0
    x = a + h
    f0 = f(a)
    while x < b:
        f1 = f(x)
        I += h * (f0 + f1) / 2
        f0 = f1
        x += min(h, b-x)
    return I
T = np.vectorize(T, excluded=['f', 'a', 'b'])

def Romberg(f, a, b, n):
    h = [0.5**k for k in range(n+1)]
    p = np.zeros([n+1, n+1])
    p[:, 0] = T(f, a, b, h)
    for j in range(n+1):
        for k in range(1, j+1):
            p[j, k] = p[j, k-1] + ( (p[j, k-1] - p[j-1, k-1]) / (4**k - 1) )
    return p[n, n]

def f(x):
    return 2 * np.sin(x)
n = 15
I = Romberg(f, 0, np.pi, n)

import time
t1 = time.time()
Romberg(f, 0, np.pi, n)
t2 = time.time()
print(t2 - t1)