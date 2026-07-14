def encrypt(data, key, encoding='utf-8'):
    if not key:
        raise ValueError("Key cannot be empty")

    if isinstance(key, str):
        key_bytes = key.encode(encoding)
    else:
        key_bytes = key

    key_length = len(key_bytes)
    return bytearray(data[i] ^ key_bytes[i % key_length] for i in range(len(data)))


def decrypt(data, key, encoding='utf-8'):
    if not key:
        raise ValueError("Key cannot be empty")

    if isinstance(key, str):
        key_bytes = key.encode(encoding)
    else:
        key_bytes = key

    key_length = len(key_bytes)
    return bytearray(data[i] ^ key_bytes[i % key_length] for i in range(len(data)))