from sys import argv

script, from_file, to_file = argv

out_data = open(to_file, 'w+').write(open(from_file, 'r').read())

