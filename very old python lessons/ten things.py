ten_things = "Apples Oranges Crows Telephones Lights Sugar"


print("Wait! Those are not ten things! Let's fix that.")

stuff = ten_things.split(' ')
more_stuff = ["day", "night", "song", "frisbee", "corn", "banana", "girl", "baby"]

while len(stuff) < 10 and len(stuff) != 10:
    next_one = more_stuff.pop()
    print("Adding: ", next_one)
    stuff.append(next_one)
    print(f"There are {len(stuff)} items in stuff")

print("Now, here are ten things: ", stuff)
print("Let's do some things with stuff")

print("beginning: ", stuff[1])
print("end: ", stuff[-1])
print(stuff.pop())
print('-'.join(stuff))
print('#'.join(stuff[3:5]))
