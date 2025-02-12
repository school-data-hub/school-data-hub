import base64
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad


def decrypt_aes_cbc_128(ciphertext_b64, key, iv):
    """
    Decrypts a string encrypted with AES CBC 128.

    Args:
        ciphertext_b64: The base64 encoded ciphertext string.
        key: The 16-byte (128-bit) key (bytes).
        iv: The 16-byte (128-bit) initialization vector (bytes).

    Returns:
        The decrypted string (UTF-8).  Returns None if an error occurs (e.g., incorrect key/IV, invalid padding).
    """
    try:
        ciphertext = base64.b64decode(ciphertext_b64)

        cipher = AES.new(key, AES.MODE_CBC, iv)

        # Decrypt and unpad
        padded_plaintext = cipher.decrypt(ciphertext)
        plaintext = unpad(padded_plaintext, AES.block_size)  # Important: Use unpad

        return plaintext.decode("utf-8")  # Decode from bytes to string

    except (ValueError, KeyError, IndexError) as e:  # Catch potential errors
        print(f"Decryption error: {e}")  # Handle or log the error
        return None  # Or raise the exception if you prefer


# Example usage (replace with your actual key, IV, and ciphertext)
key = b"Your16ByteKeyHere"  # 16 bytes for AES-128
iv = b"Your16ByteIVHere"  # 16 bytes

# Example ciphertext (replace with your base64 encoded ciphertext)
ciphertext_b64 = (
    "YourBase64EncodedCiphertextHere"  # Example: "j9+2w/w0t39v6+jV8x5pPA=="
)

decrypted_message = decrypt_aes_cbc_128(ciphertext_b64, key, iv)

if decrypted_message:
    print("Decrypted message:", decrypted_message)
else:
    print("Decryption failed.")


# Important notes and common pitfalls:

# 1. Key and IV Length:  AES-128 requires a 16-byte key and a 16-byte IV.  Make absolutely sure your key and IV are the correct length.  Incorrect lengths are a very common source of errors.

# 2. Base64 Encoding: Ciphertext is usually stored and transmitted as a base64 encoded string.  The code *must* decode the base64 before decryption.

# 3. Padding:  CBC mode requires padding.  The example uses PKCS#7 padding (the most common).  The `unpad()` function is *essential* to remove the padding after decryption.  If the padding is incorrect, you'll get a `ValueError`.

# 4. UTF-8 Decoding:  The decrypted plaintext is initially in bytes.  You must decode it to a string using the correct encoding (usually UTF-8).

# 5. Error Handling: The `try...except` block is crucial.  Many things can go wrong (wrong key/IV, corrupted ciphertext, incorrect padding).  Handle these errors gracefully.  Print an error message or return `None` (as in the example) or raise an exception - whatever is appropriate for your application.

# 6. PyCryptodome: Make sure you have the PyCryptodome library installed: `pip install pycryptodome`

# 7.  Key and IV Management:  In real-world applications, *never* hardcode keys and IVs directly into your code.  Use secure key generation and storage mechanisms.  The IV should be random and unique for each encryption.  Don't reuse IVs!

# 8.  Testing:  Test your decryption code thoroughly with known plaintext and ciphertext values to ensure it's working correctly.
