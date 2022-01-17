from sys import argv

script, filename = argv

txt = open(filename)
print(txt.read())

print("Create a new file ")
file_again = input("> ")
txt_again = open(file_again, 'w+')

print("What would you like to write? ")
words = input("> ")

txt_again.write("Here's what you wrote: \n")
txt_again.write(words)

txt.close()
txt_again.close()
