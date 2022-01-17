def add(a, b):
	print(f"{a} + {b} = ")
	return a + b

def multiply(a, b):
	print(f"{a} * {b} = ")
	return a * b

print(f"What numbers do you want to add / multiply?")
a = float(input('> '))
print("and?")
b = float(input('> '))

add = add(a, b)
multiply = multiply(a, b)

print(f"{add}, {multiply}")
