people = 30
cars = 40
trucks = 15


if cars > people:
    print("We should take the cars.")

elif cars < people:
    print("We shouldn't take the cars.")

else:
    print("I can't decide.")



if trucks > cars:
    print("That's too many trucks.")

elif trucks < cars:
    print("We could probably still fit all the people in trucks.")

else:
    print("I still can't decide.")



if people > trucks:
    print("Alright, let's just take the trucks.")

else:
    print("Fine, let's stay home then.")
