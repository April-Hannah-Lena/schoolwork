age = 20
height = 1.88
weight = "idfk"
name = 'April'
addition = "If you add age nd height you get {}"
months = "Jan\nFeb\nMar\nApr\nMay\nJun\nJul\nAug\nSept\nOct\nNov\nDec"

print(f"{name} is {height}m tall and {age} years old and {weight} pounds")
print(addition.format(age + height))
print(months)
print("""I like Internet
I like flan
\'Flan based internet videos are good\'""")

print("How old are you?", end=' ')
age = int(input("> "))
print("So", end='')
print(addition.format(age + height))
