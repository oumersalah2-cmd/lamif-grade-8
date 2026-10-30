#!/usr/bin/env python3
"""
admin_tool/activate.py
Generates an offline activation code for a given student's Device ID.

Usage:
  python3 activate.py --device-id LMF-A1B2-C3D4-E5F6
  python3 activate.py --device-id LMF-A1B2-C3D4-E5F6 --days 365
  python3 activate.py --device-id LMF-A1B2-C3D4-E5F6 --plan LIFETIME
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
PRIVATE_KEY_PATH = os.path.join(KEYS_DIR, "ed25519_private.pem")

def urlsafe_b64(b: bytes) -> str:
    return base64.urlsafe_b64encode(b).decode('ascii').rstrip('=')

def load_private_key():
    if not os.path.exists(PRIVATE_KEY_PATH):
        print(f"❌ Error: Private key not found at {PRIVATE_KEY_PATH}")
        print("   Run `python3 keygen.py` first to generate your keys.")
        sys.exit(1)
    
    with open(PRIVATE_KEY_PATH, "rb") as f:
        return serialization.load_pem_private_key(f.read(), password=None)

def generate_activation_code(device_id: str, plan: str = "LIFETIME", days: int = None) -> str:
    device_id_clean = device_id.strip().upper()
    if len(device_id_clean) < 6:
        raise ValueError("Invalid Device ID: Must be at least 6 characters.")

    payload_dict = {
        "v": 1,                     # Schema version
        "d": device_id_clean,       # Target Device ID
        "p": plan.upper(),          # Plan: LIFETIME or EXPIRING
        "t": int(time.time())       # Issuance timestamp
    }

    if days is not None and days > 0:
        expiry_ts = int(time.time()) + (days * 86400)
        payload_dict["x"] = expiry_ts
        payload_dict["p"] = "EXPIRING"

    # Canonical compact JSON
    payload_json = json.dumps(payload_dict, separators=(',', ':'), sort_keys=True)
    payload_bytes = payload_json.encode('utf-8')

    private_key = load_private_key()
    signature_bytes = private_key.sign(payload_bytes)

    payload_b64 = urlsafe_b64(payload_bytes)
    sig_b64 = urlsafe_b64(signature_bytes)

    activation_code = f"LMF1.{payload_b64}.{sig_b64}"
    return activation_code, payload_dict

def main():
    parser = argparse.ArgumentParser(description="Lamif Grade 8 Offline Activation Code Generator")
    parser.add_argument("--device-id", "-d", required=True, help="Student's Device ID (e.g. LMF-A1B2-C3D4-E5F6)")
    parser.add_argument("--plan", "-p", default="LIFETIME", choices=["LIFETIME", "EXPIRING", "PROMO"], help="Activation plan type")
    parser.add_argument("--days", type=int, default=None, help="Number of days until expiration (leave empty for lifetime)")

    args = parser.parse_args()

    try:
        code, payload = generate_activation_code(args.device_id, plan=args.plan, days=args.days)
        print("\n" + "=" * 64)
        print("🎟️  LAMIF KUTAA 8 - OFFLINE ACTIVATION CODE")
        print("=" * 64)
        print(f"Device ID:    {payload['d']}")
        print(f"Plan:         {payload['p']}")
        if "x" in payload:
            exp_date = time.strftime('%Y-%m-%d %H:%M:%S UTC', time.gmtime(payload['x']))
            print(f"Expires:      {exp_date}")
        else:
            print("Expires:      NEVER (Permanent Lifetime Access)")
        print("-" * 64)
        print("ACTIVATION CODE (Copy & send this to student):")
        print(f"\n{code}\n")
        print("=" * 64 + "\n")
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
