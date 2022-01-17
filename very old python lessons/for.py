count = [0, 1, 2, 3, 4, 5]

for i in count:
	print(i)

for num in range(0, 8):
	if num <= 4:
		print(f"{num} is less than 4")
	elif num == 4:
		print(f"{num} is equal to 4")
	else:
		print(f"{num} is greater than 4")

count.append(6)
v = 0
while v < 6:
	print(f" v == {v}")
	v = v + 1

for i in count:
	print(count[6 - i])
