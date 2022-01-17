cards = {"Tell python to make a new type of thing": "class",
	 "Two meanings: the most basic type of thing and any instance of some thing": "instance",
	 "What you get when you tell python to create a class": "instance",
	 "Inside the functions in a class, a variable for the instance/object being accessed.": "self",
	 "A phrase to say something inherits from another": "is-a",
	 "A phrase to say something is composed of other things": "has-a",
	 "Make a class named X that is-a Y": "class X(Y)",
	 "Class X has-a __init__ that takes self and j parameters": "class X(object): def __init__(self, j)",
	 "Class X has-a function named M that takes self and j parameters": "class X(object): def M(self, j)",
	 "Set foo to an instance of class X": "foo = X()",
	 "from foo get the M function and call it with parameters self, j": "foo.M(j)",
	 "From foo get the K attribute and set it to Q": "foo.K = Q"}

for defi, name in list(cards.items()):
	print(defi, "==")
	ans = input()
	if ans == name:
		print("Correct")
	else:
		print("Incorrect. Answer:")
		print(name)
	print('-' * 10)
