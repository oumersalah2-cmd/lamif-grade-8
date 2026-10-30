# Security Architecture & Hardening Guide: Lamif Kutaa 8

This document defines the security architecture, offline protections, cryptography standards, and ongoing maintenance guidelines for **Lamif Kutaa 8 Prep**.

---

## 1. Zero-Trust Offline Architecture

* **No Network Permission:** `android.permission.INTERNET` is completely absent from `AndroidManifest.xml`.
* **Zero Tracking or Analytics:** No advertising SDKs, tracking libraries, or remote telemetry are included.
* **Local Processing:** 100% of question rendering, exam scoring, timetable management, and search queries execute locally on the device CPU.

---

## 2. Cryptographic Offline Activation

* **Algorithm:** Ed25519 (RFC 8032) asymmetric digital signatures using Curve25519 point arithmetic.
* **Public Key:** Only the public key (`0843f9bbe4c3d9a2bd509931ff837b7d0489ec4f8db418d09270f4e21fcdecea`) is compiled into the app.
* **Private Key:** Stored strictly on the administrator's offline computer in `admin_tool/keys/ed25519_private.pem`. It is excluded from version control via `.gitignore`.
* **Hardware Anti-Tampering:** Local activation records are protected using an HMAC-SHA256 key stored inside the hardware **Android Keystore**, preventing direct database modification on rooted phones.
* **Clock Rollback Defense:** Timestamps are recorded sequentially to detect device clock manipulation on expiring tokens.

---

## 3. Storage & Privacy Controls

* **Device Identification:** The Device ID is generated randomly from `UUID.randomUUID()` and contains no hardware identifiers (no IMEI, MAC, or serial number).
* **Backup Rules:** Configured via `backup_rules.xml` and `data_extraction_rules.xml` to prevent sensitive credentials or activation tokens from being extracted via ADB backup tools.
* **Cleartext Traffic:** Disabled (`usesCleartextTraffic="false"`).
* **Components Export:** Activities and receivers are configured with `android:exported="false"` unless explicitly required as app entry points.

---

## 4. Yearly Maintenance & Compliance Checklist

Perform these checks annually or prior to publishing app updates:

| Category | Check Item | Frequency |
| :--- | :--- | :--- |
| **Private Key** | Verify that `admin_tool/keys/ed25519_private.pem` is backed up in at least 2 separate offline locations. | Every 6 months |
| **Target SDK** | Verify that `targetSdk` matches Google Play's required level (API 35/36). | Annually (August) |
| **16 KB Pages** | Verify build output compliance with 16 KB page size alignment on Android 15+. | Each major release |
| **Dependencies** | Run Gradle dependency updates and check for any deprecated libraries. | Every 6 months |
| **Device Testing** | Validate release `.aab` on a budget physical device (2GB RAM, Android Go edition). | Prior to submission |
