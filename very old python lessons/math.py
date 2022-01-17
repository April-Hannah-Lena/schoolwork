def add(a, b):
    print(f"add: {a} + {b}")
    return a + b

def subtract(a, b):
    print(f"subtract: {a} - {b}")
    return a - b

def multiply(a, b):
    print(f"multiply: {a} * {b}")
    return a * b

def divide(a, b):
    print(f"divide: {a} / {b}")
    return a / b


print("Let's do some math.")

age = add(30, 5)
height = subtract(78, 4)
weight = multiply(90, 2)
iq = divide(100, 2)

print(f"age: {age}, height: {height}, weight: {weight}, iq: {iq}")

what = add(age, subtract(height, multiply(weight, divide(iq, 2))))

print("what becomes ", what, "Can you do that by hand?")
