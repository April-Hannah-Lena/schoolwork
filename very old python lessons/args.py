from sys import argv

script, user_name = argv
prompt = '> '

print("Hi {}, I'm the {} script.".format(user_name, script))

print("I'd like to ask you some questions.")
print("Do you like me, {}?".format(user_name))
likes = input(prompt)

print("Where do you live, {}?".format(user_name))
lives = input(prompt)

print("What kind of computer do you use?")

print(f"""
Alright, so you said {likes} about liking me. 
You live in {lives}. Not sure where that is. 
And you have a computer. Cool cool. 
""")
