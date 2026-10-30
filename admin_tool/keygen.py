#!/usr/bin/env python3
"""
admin_tool/keygen.py
Generates an Ed25519 keypair for offline activation code generation.

Outputs:
1. admin_tool/keys/ed25519_private.pem -> PRIVATE KEY (Keep secret! NEVER share or commit)
2. Prints public key in Base64 and Hex to embed into the Android app.
"""

import os
import sys
from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization

KEYS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "keys")
PRIVATE_KEY_PATH = os.path.join(KEYS_DIR, "ed25519_private.pem")
PUBLIC_KEY_PATH = os.path.join(KEYS_DIR, "ed25519_public.pem")

def generate_keys():
    os.makedirs(KEYS_DIR, exist_ok=True)
    
    if os.path.exists(PRIVATE_KEY_PATH):
        print(f"⚠️  Private key already exists at: {PRIVATE_KEY_PATH}")
        choice = input("Overwrite? (y/N): ").strip().lower()
        if choice != "y":
            print("Aborted.")
            sys.exit(0)

    # 1. Generate Ed25519 Private Key
    private_key = ed25519.Ed25519PrivateKey.generate()
    public_key = private_key.public_key()

    # 2. Save Private Key (PEM format)
    priv_bytes = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    with open(PRIVATE_KEY_PATH, "wb") as f:
        f.write(priv_bytes)
    os.chmod(PRIVATE_KEY_PATH, 0o600)

    # 3. Save Public Key (PEM format)
    pub_bytes = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    with open(PUBLIC_KEY_PATH, "wb") as f:
        f.write(pub_bytes)

    # 4. Extract raw 32-byte public key
    raw_public_bytes = public_key.public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw
    )
    pub_hex = raw_public_bytes.hex()
    import base64
    pub_b64 = base64.b64encode(raw_public_bytes).decode('ascii')

    print("\n" + "=" * 60)
    print("✅ Ed25519 KEYPAIR GENERATED SUCCESSFULLY")
    print("=" * 60)
    print(f"📁 Private Key saved to: {PRIVATE_KEY_PATH}")
    print(f"📁 Public Key saved to:  {PUBLIC_KEY_PATH}")
    print("\n" + "🚨 WARNING: BACK UP YOUR PRIVATE KEY IN AT LEAST 2 SECURE PLACES!")
    print("   If you lose this private key, you will not be able to generate")
    print("   activation codes for future students without updating the app.")
    print("   NEVER commit this file to Git or send it to anyone.")
    print("\n" + "-" * 60)
    print("📋 PUBLIC KEY FOR ANDROID APP (ActivationConfig.kt):")
    print(f"   HEX:    {pub_hex}")
    print(f"   BASE64: {pub_b64}")
    print("-" * 60 + "\n")

if __name__ == "__main__":
    generate_keys()
