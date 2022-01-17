def print_two_words(*args):
    arg1, arg2 = args
    print(f"arg1: {arg1}, arg2: {arg2}")

def print_two_differently(arg1, arg2):
    print(f"arg1: {arg1}, arg2: {arg2}")

def print_one(arg1):
    print(f"arg1: {arg1}")

def print_none():
    print("I got nuthin'.")

a = input("put a word in: ")
b = input("put another word in: ")
c = input("put a third word in: ")

print_two_words(a, b)
print_two_differently(a, b)
print_one(c)
print_none()
