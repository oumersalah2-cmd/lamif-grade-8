# Pre-Release Device Testing Guide: Lamif Kutaa 8 Prep

This document defines the quality assurance and device compatibility testing matrix for releasing **Lamif Kutaa 8 Prep** on Google Play.

---

## 1. Physical Device Test Matrix

Given that Ethiopian students predominantly use budget Android devices on 3G/4G networks, the app must be verified across the following hardware tiers:

| Device Category | Target Specifications | Key Verification Criteria |
| :--- | :--- | :--- |
| **Low-End Android (Tier 1)** | 2 GB RAM, Quad-Core, Android 8.1 - 10 (Go Edition) | • App launches under 2.5s without Out-Of-Memory (OOM) crashes.<br>• Smooth scrolling through 60-question exams.<br>• Isar local queries execute in < 50ms. |
| **Small Screen Phones** | 320dp - 360dp width (e.g. 5.0" - 5.5" displays) | • No UI text overflows (`RenderFlex overflowed`).<br>• Option cards and touch targets remain at least 48x48dp.<br>• Question palette grid wraps cleanly. |
| **Mid-Range Android** | 3 GB - 4 GB RAM, Android 11 - 13 | • Standard daily practice, seamless background sync. |
| **Modern Flagship / Latest** | Android 14 / 15 (API 34 / 35 / 36) | • Edge-to-edge rendering.<br>• Notification runtime permission prompt (`POST_NOTIFICATIONS`). |
| **Tablets & Large Screens** | 600dp+ width (7" - 10" displays) | • Dashboard grids scale gracefully with responsive layout. |

---

## 2. Environmental Stress Scenarios

### A. Slow Network (2G / 3G Mobile Data)
- **Condition**: Network throttled to 64–128 kbps.
- **Verification**:
  - The app must load cached Isar questions instantly from local disk without spinning indicators.
  - Payment screenshot upload shows clear progress and does not time out prematurely.

### B. Complete Airplane Mode (Zero Network)
- **Condition**: Disconnect Wi-Fi and Cellular data.
- **Verification**:
  - Launch an exam, select answers, and tap finish.
  - Verify exam result is saved locally with `isSynced = false`.
  - Re-enable network: verify [exam_sync_worker.dart](file:///home/ab/lamif-grade-8/lib/features/exams/services/exam_sync_worker.dart) auto-syncs without student intervention.

### C. Battery Saver Mode
- **Condition**: Enable Android Battery Saver.
- **Verification**:
  - Countdown timer maintains accurate countdown even when the operating system throttles CPU background threads.

### D. Process Kill / Abrupt Crash Simulation
- **Condition**: In the middle of an active exam (e.g. question 12 answered), force-stop the app from Android Settings (`am force-stop`).
- **Verification**:
  - Re-open app: verify draft answers are immediately restored from local storage.

---

## 3. Running Release Builds on Physical Devices

Debug builds use the Dart JIT compiler and do NOT test R8 code shrinking or ProGuard rules. **You must test the release build on a physical device prior to publishing:**

```bash
# Connect Android phone via USB with USB Debugging enabled

# 1. Verify connected device
flutter devices

# 2. Run release build directly on device
flutter run --release

# 3. Or install the split release APK manually
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## 4. Release-Only Risk Checklist (R8 & Obfuscation)

- [ ] **Isar Native Libraries**: Verify `libisar.so` is bundled in APK `lib/` directory and Isar opens without `UnsatisfiedLinkError`.
- [ ] **JSON De-serialization**: Verify `Question.fromJson` and `ExamResult.fromJson` parse correctly without R8 renaming serialized fields.
- [ ] **WorkManager Dispatcher**: Verify Android background sync worker wakes up on network reconnect without reflection errors.
- [ ] **Crashlytics Fatal Captures**: Cause a test crash (`FirebaseCrashlytics.instance.crash()`) in a test build to confirm mapping symbols upload cleanly.
- [ ] **Release Keystore**: Verify `key.properties` points to a valid production upload key and has not defaulted to `debug.keystore`.
