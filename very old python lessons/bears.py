print("""You enter a dark room with two doors.
Do you go through door #1 or door #2?""")
door = input('> ')

if door == "1":
    print("There's a large bear here eating cheesecake. \nWhat do you do? \n1. Take the cake \n2. Scream at the bear")
    bear = input('> ')

    if bear == "1":
        print("The bear eats your face off. Good job!")
    elif bear == "2":
        print("The bear eats your legs off. Good job!")
    else: 
        print(f"I suppose diong {bear} is probably better. \nThe bear runs away.")

elif door == "2":
    print("You stare into the enldess abyss at cthulhu's retina. \n1. blueberies \n2. yellow jacket clothespins \n3. understanding revolvers and yellling melodies")
    insanity = input('> ')

    if insanity == "1" or insanity == "2":
        print("Your body survives powered by a mind of jello. \nGood job!")
    else:
        print("The insanity rots your eyes into a pool of muck. \nGood job!")

else:
    print("You fumble around and fall on a knife and die. Good job!")
