#i = 0
#numbers = []
#num = eval(input("How many numbers? ")) + 1
#increment = eval(input("How large of an increment? "))
#
#while i < num:
#    print(f"At the top i is {i}")
#    numbers.append(i)
#    i += increment
#    
#    print("Numbers now: ", numbers)
#    print(f"At the bottom i is {i}")
#
#print("The number are: ")
#
#for n in numbers:
#    print(n)
#
numbers = []
num = eval(input("How many numbers? "))
increment = eval(input("How large of an increment? "))

for n in range(0, num):
    numbers.append(1 + n * increment)
    print(f"n is {n}")

print("The numbers are: ")

for n in numbers:
    print(n)
