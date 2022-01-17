print("Let's practice everything so far.")
print('You\'d need to know \'bout escapes with \\ that do:')
print('\nnewlines and \t tabs.')

poem = """
\tthe lovely world
with logic so firmly planted
cannot discern \n the needs to love
now comprehend the passion from intuition
and requires an explanation
\n\twhere there is none.
"""

print("-----------------")
print(poem)
print("-----------------")

five = 10 - 2 + 3 - 6
print(f"This should be five: {five}")

def secret_formula(start):
    jelly_beans = start * 500
    jars = jelly_beans / 1000
    crates = jars / 100
    return jelly_beans, jars, crates

start = 10000
beans, jars, crates = secret_formula(start)

print("With a starting point of: {}".format(start))
print(f"We'd have {beans} beans, {jars} jars, and {crates} crates.")

print("We can also do that this way: ")
formula = secret_formula(start)
#easy way to apply an ordered set to a string
print("We'd have {} beans, {} jars, and {} crates.".format(*formula))
