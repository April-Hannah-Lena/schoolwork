my_name = "April"
print(f"Let's talk about {}") 

types_of_people = 10
x = f"There are {types_of_people} types of people"
print(x)

hilarious = False
alt_hilarious = True
joke_evaluation = "Isn't that joke so funny?? ... {}"
print(joke_evaluation.format(hilarious))

m = "Mary had "
l = "a little lamb"
print(m + l, end=' ')
print("and its fur was white as snow.")

formatter = "{} {} {} {}"
print(formatter.format(1, 2, 3, 4))
print(formatter.format(hilarious, alt_hilarious, False, True)

months = "Jan \nFeb \nMar \nApr \nMay \nJun \nJul \nAug \nSep \nOct \nNov \nDec"
print("Here are the months: ", months)

print("""
Multiple lines! Wow!
Who could have seen that coming?
All in the same print.
""")

tabby_cat = "\tI'm tabbed in."
persian_cat = "I'm splitting \non a line"
backslash_cat = "I'm \\ a \\ cat."

fat_cat = """
I'll do a list: 
\t* cat food
\t* fishies
\t* catnip \n\t* grass
