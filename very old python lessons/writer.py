from sys import argv
script, filename = argv

print("This is the file eraser")
print("We're going to erase {}".format(filename))

print("""
If you want this, hit RETURN. 
If you don't want this, hit Ctrl-C \(^C\).
""")
input('> ')

print("Opening the file...")
target = open(filename, 'w')

print("Truncating the file. l8r data.")
target.truncate()

print("Now we're going to replace it with three new lines.")

line1 = input("line 1: ")
line2 = input("line 2: ")
line3 = input("line 3: ")

poem = "{}\n{}\n{}\n"

print("Writing these lines to the file...")

target.write(poem.format(line1, line2, line3))

print("And the we close the file.")
target.close()
