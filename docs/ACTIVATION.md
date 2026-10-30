# Lamif Kutaa 8 - Offline Activation System

This document explains the architecture, security, and operation of the **100% Offline Activation System** for Lamif Kutaa 8 Exam Prep.

---

## 1. Architectural Overview

The app operates completely **offline** without internet access, third-party servers, or Firebase. To enable students to activate the full national mock exams securely without requiring network connectivity, the system uses **asymmetric Ed25519 digital signatures** (RFC 8032):

```
+--------------------------------------------------------------------+
| ADMIN COMPUTER (Offline)                                           |
| - Holds: ed25519_private.pem (SECRET)                              |
| - Runs: python3 admin_tool/activate.py -d <DEVICE_ID>              |
| - Generates: Signed Activation Token (LMF1.payload.signature)      |
+--------------------------------------------------------------------+
                                  |
                                  v (SMS / Paper / Telegram / Word of mouth)
+--------------------------------------------------------------------+
| STUDENT PHONE (Offline - Zero Network Required)                    |
| - Contains: Ed25519 Public Key ONLY                                |
| - Shows: Unique Device ID (Random UUID-derived)                    |
| - Verifies: Ed25519 Signature against Public Key                   |
| - Stores: Room SQLite + Hardware Android Keystore HMAC             |
+--------------------------------------------------------------------+
```

---

## 2. Security & Anti-Tamper Protections

### A. Non-Hardware Device ID
* **Privacy by Design:** The app never accesses sensitive phone hardware identifiers (IMEI, MAC address, IMSI, or Android ID).
* **Generation:** Generated once on first install from a cryptographically secure random `UUID`:
  `LMF-XXXX-XXXX-XXXX`
* **Persistence:** Saved in local `SharedPreferences` and Room SQLite. It remains constant across app updates.

### B. Ed25519 Asymmetric Signatures (RFC 8032)
* The student's device contains **ONLY** the 32-byte public key (`ActivationConfig.kt`).
* Only the administrator possessing the secret `ed25519_private.pem` can generate valid codes.
* Any tampering with the payload (e.g. changing the Device ID, modifying the plan from Annual to Lifetime) alters the hash and causes mathematical verification to fail immediately.

### C. Android Keystore Hardware HMAC Anti-Tampering
* If an attacker roots their device and modifies the SQLite database (`activation` table) using a local database editor, the app detects it.
* When activation occurs, the app calculates an HMAC-SHA256 signature over `(deviceId, plan, expiry, token)` using a key generated inside the phone's **hardware-isolated Android Keystore**.
* On startup, if the database record does not match the Keystore HMAC, the activation is rejected.

### D. Clock Rollback Tampering Defense
* For expiring/annual licenses: students might attempt to roll back their device clock into the past to prevent expiration.
* The app records `lastKnownTimestamp` inside the protected store.
* If `currentTime < lastKnownTimestamp - 300` (allowing up to 5 minutes tolerance for standard clock adjustments), clock rollback tampering is detected and locked content remains protected.

---

## 3. Activation Code Format

Activation codes use a clean URL-safe token structure:

```
LMF1.<PAYLOAD_BASE64URL>.<SIGNATURE_BASE64URL>
```

1. **Prefix:** `LMF1.` identifies the token format and version.
2. **Payload (Base64URL):** Canonical JSON containing:
   * `v`: Schema version (`1`)
   * `d`: Target Device ID (`LMF-A1B2-C3D4-E5F6`)
   * `p`: Plan type (`LIFETIME` or `EXPIRING`)
   * `t`: Issue timestamp
   * `x`: Expiration timestamp (optional)
3. **Signature (Base64URL):** 64-byte Ed25519 raw signature.

---

## 4. Free Sample Content vs. Locked Ministry Exams

* **100% Free Practice Mode:**
  * Sample exams (e.g. 2015 E.C. past exam questions and topic practice quizzes) are completely free for all students without any activation.
* **Full Ministry Mock Exams:**
  * Complete timed national mock exams (e.g. 2016 E.C. full exam) have a lock indicator (`🔒`).
  * Tapping a locked exam displays a dialog directing the student to their **Device ID** and the offline activation input.

---

## 5. Admin Tool Usage Guide (`/admin_tool`)

The admin tool is located in the `admin_tool/` folder and is **NOT** included in the Android application bundle.

### ⚠️ CRITICAL PRIVATE KEY BACKUP WARNING
> **BACK UP YOUR PRIVATE KEY IN AT LEAST 2 SECURE PLACES!**
> The private key is located at: `admin_tool/keys/ed25519_private.pem`
> * If you lose this key, you will never be able to generate activation codes for future students without rebuilding and updating the app on Google Play.
> * **NEVER** commit this key to Git, push it to GitHub, or share it. It is strictly listed in `.gitignore`.

### A. Generating a Lifetime Activation Code
```bash
python3 admin_tool/activate.py --device-id "LMF-A1B2-C3D4-E5F6"
```

**Output:**
```
================================================================
🎟️  LAMIF KUTAA 8 - OFFLINE ACTIVATION CODE
================================================================
Device ID:    LMF-A1B2-C3D4-E5F6
Plan:         LIFETIME
Expires:      NEVER (Permanent Lifetime Access)
----------------------------------------------------------------
ACTIVATION CODE (Copy & send this to student):

LMF1.eyJkIjoiTE1GLUExQjItQzNENC1FNUY2IiwicCI6IkxJRkVUSU1FIiwidCI6MTc5MzM4OTM5MSwidiI6MX0.ijiSqNBlHUqibLKSRGwT3-4c6O5-T0_ltpBWOJRwxg_GtqOChoQPU1nciZTm9Vgn8KOx4JWZ1g1e-Uc-VeCtBw
================================================================
```

### B. Generating a 1-Year (365 Days) Expiring Code
```bash
python3 admin_tool/activate.py --device-id "LMF-A1B2-C3D4-E5F6" --days 365
```

### C. Verifying an Activation Code
```bash
python3 admin_tool/verify.py --code "LMF1.ey..." --device-id "LMF-A1B2-C3D4-E5F6"
```

---

## 6. Student Activation Experience (In App)

1. The student opens **Profile** -> **Mirkaneessa Moobaayilaa (Activation)** (or taps on any locked mock exam).
2. The screen clearly displays their **Device ID** with a **Waraabi (Copy)** button.
3. The student provides their Device ID to the admin.
4. The admin generates an activation code with `activate.py` and sends the text back to the student.
5. The student pastes the code into the app and taps **Mirkaneessi (Activate)**.
6. The app instantly verifies the cryptographic signature offline, confirms the Device ID matches, saves the activation securely in Room + Keystore, and unlocks all exams permanently.
