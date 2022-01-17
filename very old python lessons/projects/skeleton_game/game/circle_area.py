from math import pi

def area(r):

	if not(type(r) in [int, float]) or r < 0:
		raise ValueError("input must be nonnegative real number")

	else:
		area = (r**2) * pi
		return area
