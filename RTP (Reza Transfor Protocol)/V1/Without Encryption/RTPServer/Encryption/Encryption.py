def encrypt(data, key):
    if not key:
        raise ValueError("Key cannot be empty")
    key_length = len(key)
    return bytearray(data[i] ^ key[i % key_length] for i in range(len(data)))

def decrypt(data, key):
    if not key:
        raise ValueError("Key cannot be empty")
    key_length = len(key)
    return bytearray(data[i] ^ key[i % key_length] for i in range(len(data)))