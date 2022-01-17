print("Type a string")
string = input('> ')

start = 0

def encode_binary(character):
    character_binary = bin(int.from_bytes(string[character].encode(), byteorder='big'))
    print(character_binary, end='  ')

    if character < len(string) - 1:
        character = character + 1
        return encode_binary(character)


print(f"\nBinary conversion for characters in your string: {string}")
print("-------------------------------------------")
encode_binary(start)
print("\n-------------------------------------------")
