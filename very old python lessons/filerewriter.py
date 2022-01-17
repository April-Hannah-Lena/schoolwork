from sys import argv
from os.path import exists

script, input, output = argv

print(f"Valid input file? {exists(input)}. Valid output file? {exists(output)}.")
print(f"Cut data from {input} to {output}?", end='[Enter/Ctrl-d]')
input('')

indata = open(input).read()
print(f"Copying {len(indata)} bytes.")


open(output, 'w').write(indata)
close(input)
close(output)
