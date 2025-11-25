# Broken Cipher
## Challenge:
<img width="563" height="613" alt="image" src="https://github.com/user-attachments/assets/69c418ce-5343-4572-baae-f8cd800945b0" />

## Solution:
We are given a few files:
- `oblivion_cypher.py` - The encryption source code
- `public_key.pem` - A public key file
- `encrypted_message.bin` - File with an encrypted message. Most likely the flag

We first need to analyse how the encryption works. Looking at the Python code, it starts from the `main()` function.
```python
def main():
    """
    Example usage of OBLIVION encryption system
    """
    import sys
    
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <message> <public_key.pem>")
        print("Example: python3 oblivion_cipher.py 'EXECUTE ORDER 66' public_key.pem")
        sys.exit(1)
    
    message = sys.argv[1]
    public_key_path = sys.argv[2]
    
    try:
        encrypted = encrypt_command(message, public_key_path)
        
        # Output encrypted data
        with open('encrypted_output.bin', 'wb') as f:
            f.write(encrypted)
        
        print(f"[OBLIVION] Message encrypted successfully")
        print(f"[OBLIVION] Output written to: encrypted_output.bin")
        print(f"[OBLIVION] Encrypted size: {len(encrypted)} bytes")
        
    except Exception as e:
        print(f"[ERROR] Encryption failed: {e}")
        sys.exit(1)
```
The code takes in 3 arguments (including the Python script itself) in the form of `python <argument 0, which is the script> <argument 1, the message> <argument 2, the public key file`. It then runs the encryption with the `encrypt_command` function.
</br></br>
We then take a look at the function.
```python
def encrypt_command(message, public_key_path):
    """
    Encrypts a command message using hybrid encryption.
    
    Security layers:
    1. RSA-2048 encryption for key exchange (REDACTED: Actually 512-bit for performance)
    2. AES-128-CTR for message encryption
    3. PKCS#1 OAEP padding for RSA
    
    Args:
        message (str): Command message to encrypt
        public_key_path (str): Path to RSA public key
    
    Returns:
        bytes: Encrypted data (RSA encrypted AES key + AES encrypted message)
    """
    # Load public key
    with open(public_key_path, 'rb') as f:
        public_key = RSA.import_key(f.read())
    
    # Generate session key for AES
    aes_key = get_random_bytes(16)  # 128-bit key
    
    # Encrypt the AES key with RSA
    rsa_cipher = PKCS1_OAEP.new(public_key)
    encrypted_aes_key = rsa_cipher.encrypt(aes_key)
    
    # Encrypt the message with AES-CTR
    # Note: CTR mode requires a nonce/counter
    # For OBLIVION's deterministic protocol, we use a fixed nonce
    # TODO: Security review - is fixed nonce acceptable for our use case?
    nonce = b'\x00' * 8  # Fixed 64-bit nonce for consistency
    cipher = AES.new(aes_key, AES.MODE_CTR, nonce=nonce)
    encrypted_message = cipher.encrypt(message.encode('utf-8'))
    
    # Combine encrypted key and encrypted message
    return encrypted_aes_key + encrypted_message
```
The code comments tell us that there's 3 layers of encryption:
1. RSA-2048 for the key exchange
2. AES-128-CTR for message encryption
3. PKCS#1 OAEP padding for RSA

However, we notice two vulnerabilities in the code:
1. RSA-2048 encryption for key exchange (REDACTED: Actually 512-bit for performance)
2. TODO: Security review - is fixed nonce acceptable for our use case?

### Vulnerability 1: Weak RSA Key Size (CRITICAL)

**Claimed**: 2048-bit RSA</br>
**Actual**: 512-bit RSA

#### Why this matters:
- 512-bit RSA can be factored in hours on modern hardware
- 2048-bit RSA would take billions of years to break
- This is the primary attack vector

### Vulnerability 2: Fixed Nonce in AES-CTR

**Problem**: Reusing the same nonce with the same key breaks CTR mode security. </br>
**Impact**: If we can recover the AES key (via RSA breaking), the fixed nonce doesn't matter. But this would be critical in other scenarios.

### Solving the Challenge
The encrypted file has a specific structure:
```
[64 bytes: RSA-encrypted AES key] + [N bytes: AES-encrypted message]
```
Why 64 bytes? 512-bit RSA = 512 bits = 64 bytes.

First, we need to extract the modulus (n) and public exponent (e) from the public key file. We con do this with Python:
```python
from Crypto.PublicKey import RSA

with open('public_key.pem', 'rb') as f:
    public_key = RSA.import_key(f.read())

n = public_key.n  # The modulus to factor
e = public_key.e  # Usually 65537
```

Since it's 512-bit RSA, we can factor the modulus n into its prime factors p and q.
#### What is RSA Factoring?
- RSA security relies on n = p × q being hard to factor
- Private key requires knowing p and q
- 512-bit numbers can be factored with modern tools

#### Tools for Factorization:
1. FactorDB - Online database of factored numbers
2. YAFU - Specialized factorization tool
3. SymPy - Python library for mathematical operations

```python
import factordb

def factor_modulus(n):
    f = factordb.FactorDB(n)
    f.connect()
    factors = f.get_factor_list()
    
    if len(factors) == 2:
        p, q = factors
        return p, q
    else:
        raise Exception("Factorization failed")
```

Once we have p and q, we can compute the private exponent d:
```python
def reconstruct_private_key(n, e, p, q):
    # Compute Euler's totient function
    phi = (p - 1) * (q - 1)
    
    # Compute private exponent d
    d = pow(e, -1, phi)  # Modular inverse
    
    # Reconstruct private key
    private_key = RSA.construct((n, e, d, p, q))
    return private_key
```

Using the recovered private key, decrypt the first 64 bytes of the encrypted file:
```python
def decrypt_aes_key(encrypted_data, private_key):
    # Extract encrypted AES key (first 64 bytes)
    encrypted_aes_key = encrypted_data[:64]
    
    # Decrypt with RSA
    rsa_cipher = PKCS1_OAEP.new(private_key)
    aes_key = rsa_cipher.decrypt(encrypted_aes_key)
    
    return aes_key
```

Finally, use the AES key with the same fixed nonce to decrypt the message:
```python
def decrypt_message(encrypted_data, aes_key):
    # Extract encrypted message (after first 64 bytes)
    encrypted_message = encrypted_data[64:]
    
    # Use the same fixed nonce as encryption
    nonce = b'\x00' * 8
    cipher = AES.new(aes_key, AES.MODE_CTR, nonce=nonce)
    plaintext = cipher.decrypt(encrypted_message)
    
    return plaintext.decode('utf-8')
```

### The Complete Exploit Code
```python
#!/usr/bin/env python3
"""
OBLIVION Decryption Tool
CTF Solution for the vulnerable encryption scheme
"""

from Crypto.PublicKey import RSA
from Crypto.Cipher import AES, PKCS1_OAEP
import requests
import subprocess

def factor_rsa_modulus(n):
    """
    Factor 512-bit RSA modulus using online factorization services
    or local tools like yafu, msieve, or factordb
    """
    # Try factordb first
    try:
        import factordb
        f = factordb.FactorDB(n)
        f.connect()
        factors = f.get_factor_list()
        if len(factors) == 2:
            return factors[0], factors[1]
    except:
        pass
    
    # Alternative: Use sympy if the factors are small enough
    try:
        from sympy import factorint
        factors = factorint(n)
        if len(factors) == 2:
            p, q = list(factors.keys())
            return p, q
    except:
        pass
    
    # If automatic factorization fails, we'll need to use external tools
    print("Attempting factorization with external tools...")
    try:
        # Save modulus to file for yafu
        with open('modulus.txt', 'w') as f:
            f.write(f"factor({n})")
        
        # Try yafu (if installed)
        result = subprocess.run(['yafu', 'factor', str(n)], capture_output=True, text=True)
        if 'P' in result.stdout and 'Q' in result.stdout:
            lines = result.stdout.split('\n')
            for line in lines:
                if 'P =' in line:
                    p = int(line.split('=')[1].strip())
                elif 'Q =' in line:
                    q = int(line.split('=')[1].strip())
            return p, q
    except:
        pass
    
    raise Exception("Failed to factor modulus. Try using factordb.com manually")

def decrypt_message(encrypted_file_path, public_key_path):
    """
    Decrypt the OBLIVION encrypted message by exploiting the vulnerabilities
    """
    # Load public key to get the modulus
    with open(public_key_path, 'rb') as f:
        public_key = RSA.import_key(f.read())
    
    # The RSA key size is actually 512-bit (vulnerable)
    n = public_key.n
    e = public_key.e
    
    print(f"[*] RSA Modulus (n): {n}")
    print(f"[*] Public Exponent (e): {e}")
    print(f"[*] Key size: {n.bit_length()} bits")
    
    # Factor the modulus to get p and q
    print("[*] Factoring RSA modulus...")
    p, q = factor_rsa_modulus(n)
    
    print(f"[+] Found factors:")
    print(f"    p = {p}")
    print(f"    q = {q}")
    
    # Verify factorization
    if p * q != n:
        raise Exception("Factorization failed!")
    
    # Reconstruct private key
    phi = (p - 1) * (q - 1)
    d = pow(e, -1, phi)  # Modular inverse
    
    # Create private key
    private_key = RSA.construct((n, e, d, p, q))
    
    # Load encrypted data
    with open(encrypted_file_path, 'rb') as f:
        encrypted_data = f.read()
    
    # RSA key size in bytes (512 bits = 64 bytes)
    rsa_key_size = 64
    encrypted_aes_key = encrypted_data[:rsa_key_size]
    encrypted_message = encrypted_data[rsa_key_size:]
    
    # Decrypt AES key
    rsa_cipher = PKCS1_OAEP.new(private_key)
    aes_key = rsa_cipher.decrypt(encrypted_aes_key)
    
    print(f"[+] AES key recovered: {aes_key.hex()}")
    
    # Decrypt message with AES-CTR using the fixed nonce
    nonce = b'\x00' * 8  # Same fixed nonce as encryption
    cipher = AES.new(aes_key, AES.MODE_CTR, nonce=nonce)
    decrypted_message = cipher.decrypt(encrypted_message)
    
    return decrypted_message

def simple_decrypt_with_private_key(encrypted_file_path, private_key_path):
    """
    Alternative: If you already have the private key
    """
    # Load private key
    with open(private_key_path, 'rb') as f:
        private_key = RSA.import_key(f.read())
    
    # Load encrypted data
    with open(encrypted_file_path, 'rb') as f:
        encrypted_data = f.read()
    
    # Extract encrypted AES key (first 64 bytes for 512-bit RSA)
    encrypted_aes_key = encrypted_data[:64]
    encrypted_message = encrypted_data[64:]
    
    # Decrypt AES key
    rsa_cipher = PKCS1_OAEP.new(private_key)
    aes_key = rsa_cipher.decrypt(encrypted_aes_key)
    
    # Decrypt message with fixed nonce
    nonce = b'\x00' * 8
    cipher = AES.new(aes_key, AES.MODE_CTR, nonce=nonce)
    decrypted_message = cipher.decrypt(encrypted_message)
    
    return decrypted_message

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) not in [2, 3]:
        print("Usage:")
        print("  python3 decrypt_oblivion.py encrypted_message.bin")
        print("  python3 decrypt_oblivion.py encrypted_message.bin public_key.pem")
        sys.exit(1)
    
    encrypted_file = sys.argv[1]
    
    try:
        if len(sys.argv) == 3:
            # Method 1: Factor public key and decrypt
            public_key_file = sys.argv[2]
            result = decrypt_message(encrypted_file, public_key_file)
        else:
            # Method 2: Use existing private key
            result = simple_decrypt_with_private_key(encrypted_file, 'private_key.pem')
        
        print(f"\n[SUCCESS] Decrypted message:")
        print(result.decode('utf-8', errors='replace'))
        
    except Exception as e:
        print(f"[ERROR] Decryption failed: {e}")
        print("\nTroubleshooting tips:")
        print("1. Ensure you have the required dependencies: pycryptodome, factordb-pycli")
        print("2. For factorization, you might need to install yafu or use factordb.com manually")
        print("3. If automatic factorization fails, try:")
        print("   - Visit factordb.com and enter the modulus from public_key.pem")
        print("   - Use: openssl rsa -pubin -in public_key.pem -text -noout")
        print("   - Extract modulus and factor it manually")
```

<img width="1463" height="538" alt="image" src="https://github.com/user-attachments/assets/104151c6-3391-45cb-814b-2207cfc43311" />

The flag is `ZEROCODEKEY{F3rm4t_4tt4ck_0n_cl0s3_pr1m3s_br34ks_RS4_l1k3_gl4ss}`.

### Cryptographic Concepts Explained
#### RSA Mathematics
Key Generation:
1. Choose two large primes p and q
2. Compute n = p × q (modulus)
3. Compute φ(n) = (p-1)(q-1) (Euler's totient)
4. Choose e such that 1 < e < φ(n) and gcd(e, φ(n)) = 1
5. Compute d = e⁻¹ mod φ(n) (private exponent)

**Encryption:** c = mᵉ mod n</br>
**Decryption:** m = cᵈ mod n

#### Why 512-bit RSA is Breakable
- 1999: 512-bit RSA was first publicly broken
- 2009: 768-bit RSA broken (took 2+ years)
- 2024: 512-bit RSA can be broken in hours on a laptop
- Many 512-bit numbers are pre-computed in databases

#### AES-CTR Mode
- CTR mode turns AES into a stream cipher
- Encrypts a counter value to generate keystream
- Critical: Never reuse (key, nonce) pair
- Fixed nonce = same keystream if same key
