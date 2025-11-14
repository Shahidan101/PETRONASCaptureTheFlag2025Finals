#!/usr/bin/env python3
"""
OBLIVION Encryption Module v2.147
Classification: TOP SECRET
Purpose: Secure communication between OBLIVION nodes

WARNING: This module is critical to OBLIVION's infrastructure.
Unauthorized analysis or tampering will be detected and eliminated.
"""

from Crypto.PublicKey import RSA
from Crypto.Cipher import AES, PKCS1_OAEP
from Crypto.Random import get_random_bytes

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

if __name__ == "__main__":
    main()
