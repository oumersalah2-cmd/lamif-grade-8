#!/usr/bin/env python3
"""
admin_tool/verify.py
Verifies an offline activation code against the public key and device ID.

Usage:
  python3 verify.py --code LMF1.ey... --device-id LMF-A1B2-C3D4-E5F6
"""

import argparse
import base64
import json
import os
import sys
import time
from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization

KEYS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "keys")
PUBLIC_KEY_PATH = os.path.join(KEYS_DIR, "ed25519_public.pem")

def urlsafe_b64decode(s: str) -> bytes:
    # Add back padding
    rem = len(s) % 4
    if rem > 0:
        s += '=' * (4 - rem)
    return base64.urlsafe_b64decode(s.encode('ascii'))

def load_public_key():
    if not os.path.exists(PUBLIC_KEY_PATH):
        print(f"❌ Error: Public key not found at {PUBLIC_KEY_PATH}")
        sys.exit(1)
    with open(PUBLIC_KEY_PATH, "rb") as f:
        return serialization.load_pem_public_key(f.read())

def verify_code(code: str, expected_device_id: str = None):
    parts = code.strip().split('.')
    if len(parts) != 3 or parts[0] != "LMF1":
        return False, "Invalid code format (must start with LMF1 and have 3 parts)."

    try:
        payload_bytes = urlsafe_b64decode(parts[1])
        sig_bytes = urlsafe_b64decode(parts[2])
    except Exception as e:
        return False, f"Base64 decoding failed: {e}"

    if len(sig_bytes) != 64:
        return False, f"Invalid signature length ({len(sig_bytes)} bytes, expected 64)."

    pub_key = load_public_key()
    try:
        pub_key.verify(sig_bytes, payload_bytes)
    except Exception:
        return False, "Cryptographic signature check FAILED (Bad signature or tampered code)."

    try:
        payload = json.loads(payload_bytes.decode('utf-8'))
    except Exception as e:
        return False, f"Malformed JSON payload: {e}"

    if expected_device_id:
        if payload.get("d") != expected_device_id.strip().upper():
            return False, f"Device ID mismatch! Token is for '{payload.get('d')}', but expected '{expected_device_id}'."

    # Check expiration
    if "x" in payload:
        exp_ts = payload["x"]
        if time.time() > exp_ts:
            return False, f"Token has EXPIRED on {time.strftime('%Y-%m-%d %H:%M:%S UTC', time.gmtime(exp_ts))}."

    return True, payload

def main():
    parser = argparse.ArgumentParser(description="Verify Lamif Grade 8 Offline Activation Code")
    parser.add_argument("--code", "-c", required=True, help="Activation code to verify")
    parser.add_argument("--device-id", "-d", help="Optional expected Device ID to check against")

    args = parser.parse_args()
    valid, result = verify_code(args.code, args.device_id)

    if valid:
        print("\n✅ ACTIVATION CODE IS VALID!")
        print(json.dumps(result, indent=2))
        print()
    else:
        print(f"\n❌ ACTIVATION CODE REJECTED: {result}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
