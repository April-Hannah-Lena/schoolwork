people = input("people: ")
cats = input("cats: ")
dogs = int(25)

if people < cats:
    print("Too many cats! What do we do?")

if people > cats:
    print("Not very many cats. The world is how it should be. This developer is a dog person.")

if people < dogs:
    print("So many dogs! The world will be filled with more love, and pats.")

if people > dogs:
    print("We need more dogs!")

#dogs += 5   ==   dogs = dogs + 5
dogs = dogs + 5
print("")

if people >= dogs:
    print("People are greater than or equal to dogs")

if people <= dogs:
    print("People are less than or equal to dogs.")

if people == dogs:
    print("People are dogs.")
