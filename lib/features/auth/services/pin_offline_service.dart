import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/payment_status.dart';
import '../models/student_track.dart';

/// Service managing offline PIN verification, secure token persistence,
/// exponential lockout escalation, and the 21-day offline grace period.
class PinOfflineService {
  final FlutterSecureStorage _storage;

  // Secure Storage Keys
  static const String keyLocalPinHash = 'sec_pin_hash_v1';
  static const String keyLocalPinSalt = 'sec_pin_salt_v1';
  static const String keyAccessToken = 'sec_jwt_access_token';
  static const String keyRefreshToken = 'sec_jwt_refresh_token';
  static const String keyUserUid = 'sec_user_uid';
  static const String keyUserPhone = 'sec_user_phone';
  static const String keyUserName = 'sec_user_name';
  static const String keyUserSchoolZone = 'sec_user_school_zone';
  static const String keyUserSchoolName = 'sec_user_school_name';
  static const String keyUserTrack = 'sec_user_track';
  static const String keyPaymentStatus = 'sec_payment_status';
  static const String keyPaymentCachedEpoch = 'sec_payment_cached_epoch';
  static const String keyOfflineGraceDeadline = 'sec_grace_deadline_epoch';
  static const String keyLastOnlineSync = 'sec_last_online_sync_epoch';

  // Lockout Management Keys
  static const String keyFailedAttempts = 'sec_lockout_failed_attempts';
  static const String keyLockoutUntilEpoch = 'sec_lockout_until_epoch';
  static const String keyLifetimeFailures = 'sec_lockout_lifetime_failures';

  static const int kDefaultOfflineGraceDays = 21;
  static const int kPbkdf2Iterations = 10000;

  PinOfflineService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  // ==========================================================================
  // PBKDF2 Slow Key Derivation Function (Crypto Package)
  // ==========================================================================

  /// Derives a cryptographically strong salted hash of the 6-digit PIN
  /// using PBKDF2-HMAC-SHA256 with 10,000 iterations.
  static String derivePinHash(String pin, String saltBase64) {
    final saltBytes = base64Decode(saltBase64);
    final pinBytes = utf8.encode(pin);

    // PBKDF2-HMAC-SHA256 implementation
    final hmac = Hmac(sha256, pinBytes);
    
    // First block U1 = PRF(P, S || INT(1))
    final intBlock = Uint8List(4)..buffer.asByteData().setInt32(0, 1, Endian.big);
    final u1Data = <int>[...saltBytes, ...intBlock];
    var u = hmac.convert(u1Data).bytes;
    var result = List<int>.from(u);

    // Iterations U2...Uc
    for (int i = 1; i < kPbkdf2Iterations; i++) {
      u = hmac.convert(u).bytes;
      for (int k = 0; k < result.length; k++) {
        result[k] ^= u[k];
      }
    }

    return base64Encode(result);
  }

  /// Generates 16 bytes of cryptographically secure random salt
  static String generateRandomSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(values);
  }

  // ==========================================================================
  // PIN Storage & Offline Verification
  // ==========================================================================

  /// Stores derived salted hash of PIN and its salt in secure storage
  Future<void> saveLocalPin(String pin) async {
    final salt = generateRandomSalt();
    final hash = derivePinHash(pin, salt);
    await _storage.write(key: keyLocalPinSalt, value: salt);
    await _storage.write(key: keyLocalPinHash, value: hash);
  }

  /// Checks if a PIN is configured locally for offline authentication
  Future<bool> hasConfiguredPin() async {
    final hash = await _storage.read(key: keyLocalPinHash);
    return hash != null && hash.isNotEmpty;
  }

  /// Verifies an entered PIN against the local salted PBKDF2 hash
  Future<bool> verifyOfflinePin(String pin) async {
    final storedHash = await _storage.read(key: keyLocalPinHash);
    final storedSalt = await _storage.read(key: keyLocalPinSalt);

    if (storedHash == null || storedSalt == null) return false;

    final computedHash = derivePinHash(pin, storedSalt);
    // Constant-time comparison to prevent timing side-channel attacks
    return _constantTimeEquals(computedHash, storedHash);
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // ==========================================================================
  // Local Lockout Escalation (5 fails -> 5m, 15m, 60m; 10 fails -> online reset)
  // ==========================================================================

  /// Retrieves current lockout status
  Future<LockoutStatus> getLockoutStatus() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lockoutEpochStr = await _storage.read(key: keyLockoutUntilEpoch);
    final failedAttemptsStr = await _storage.read(key: keyFailedAttempts);
    final lifetimeFailuresStr = await _storage.read(key: keyLifetimeFailures);

    final lockoutEpoch = int.tryParse(lockoutEpochStr ?? '0') ?? 0;
    final failedAttempts = int.tryParse(failedAttemptsStr ?? '0') ?? 0;
    final lifetimeFailures = int.tryParse(lifetimeFailuresStr ?? '0') ?? 0;

    // After 10 lifetime failed attempts without successful online recovery, require online reset
    if (lifetimeFailures >= 10) {
      return const LockoutStatus(
        isLocked: true,
        remainingSeconds: 0,
        failedAttempts: 10,
        requiresOnlineRecovery: true,
      );
    }

    if (now < lockoutEpoch) {
      final remainingSeconds = ((lockoutEpoch - now) / 1000).ceil();
      return LockoutStatus(
        isLocked: true,
        remainingSeconds: remainingSeconds,
        failedAttempts: failedAttempts,
        requiresOnlineRecovery: false,
      );
    }

    return LockoutStatus(
      isLocked: false,
      remainingSeconds: 0,
      failedAttempts: failedAttempts,
      requiresOnlineRecovery: false,
    );
  }

  /// Records a wrong PIN attempt and computes escalation lockout
  Future<LockoutStatus> recordFailedPinAttempt() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final failedAttemptsStr = await _storage.read(key: keyFailedAttempts);
    final lifetimeFailuresStr = await _storage.read(key: keyLifetimeFailures);

    int failedAttempts = (int.tryParse(failedAttemptsStr ?? '0') ?? 0) + 1;
    int lifetimeFailures = (int.tryParse(lifetimeFailuresStr ?? '0') ?? 0) + 1;

    await _storage.write(key: keyFailedAttempts, value: failedAttempts.toString());
    await _storage.write(key: keyLifetimeFailures, value: lifetimeFailures.toString());

    if (lifetimeFailures >= 10) {
      return const LockoutStatus(
        isLocked: true,
        remainingSeconds: 0,
        failedAttempts: 10,
        requiresOnlineRecovery: true,
      );
    }

    int lockoutMinutes = 0;
    if (failedAttempts == 5) {
      lockoutMinutes = 5;
    } else if (failedAttempts == 6) {
      lockoutMinutes = 15;
    } else if (failedAttempts >= 7) {
      lockoutMinutes = 60;
    }

    if (lockoutMinutes > 0) {
      final lockoutUntil = now + (lockoutMinutes * 60 * 1000);
      await _storage.write(key: keyLockoutUntilEpoch, value: lockoutUntil.toString());
      return LockoutStatus(
        isLocked: true,
        remainingSeconds: lockoutMinutes * 60,
        failedAttempts: failedAttempts,
        requiresOnlineRecovery: false,
      );
    }

    return LockoutStatus(
      isLocked: false,
      remainingSeconds: 0,
      failedAttempts: failedAttempts,
      requiresOnlineRecovery: false,
    );
  }

  /// Resets failed attempt counter upon successful PIN unlock
  Future<void> resetLockoutOnSuccess() async {
    await _storage.delete(key: keyFailedAttempts);
    await _storage.delete(key: keyLockoutUntilEpoch);
    // Lifetime failures are also reset upon successful authenticated PIN entry
    await _storage.delete(key: keyLifetimeFailures);
  }

  // ==========================================================================
  // Offline Grace Window (Default: 21 Days)
  // ==========================================================================

  /// Sets or updates the offline grace deadline (invoked after online sync/login)
  Future<void> refreshOfflineGracePeriod({int graceDays = kDefaultOfflineGraceDays}) async {
    final now = DateTime.now();
    final deadline = now.add(Duration(days: graceDays));
    await _storage.write(key: keyLastOnlineSync, value: now.millisecondsSinceEpoch.toString());
    await _storage.write(key: keyOfflineGraceDeadline, value: deadline.millisecondsSinceEpoch.toString());
  }

  /// Returns remaining days in the offline grace window. Negative if expired.
  Future<int> getRemainingGraceDays() async {
    final deadlineStr = await _storage.read(key: keyOfflineGraceDeadline);
    if (deadlineStr == null) return 0;

    final deadlineEpoch = int.tryParse(deadlineStr) ?? 0;
    final deadline = DateTime.fromMillisecondsSinceEpoch(deadlineEpoch);
    final difference = deadline.difference(DateTime.now()).inDays;
    return difference;
  }

  /// Returns true if student has exceeded the offline grace window
  Future<bool> isGracePeriodExpired() async {
    final days = await getRemainingGraceDays();
    return days < 0;
  }

  // ==========================================================================
  // Session Token & Profile Storage
  // ==========================================================================

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: keyAccessToken, value: accessToken);
    await _storage.write(key: keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: keyRefreshToken);

  Future<void> saveUserProfile({
    required String uid,
    required String phone,
    required String name,
    required String schoolZone,
    String? schoolName,
    required StudentTrack track,
    required PaymentStatus paymentStatus,
  }) async {
    await _storage.write(key: keyUserUid, value: uid);
    await _storage.write(key: keyUserPhone, value: phone);
    await _storage.write(key: keyUserName, value: name);
    await _storage.write(key: keyUserSchoolZone, value: schoolZone);
    if (schoolName != null) {
      await _storage.write(key: keyUserSchoolName, value: schoolName);
    }
    await _storage.write(key: keyUserTrack, value: track.storageValue);
    await _storage.write(key: keyPaymentStatus, value: paymentStatus.prismaValue);
    await _storage.write(
      key: keyPaymentCachedEpoch,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Future<Map<String, String?>> getUserProfile() async {
    return {
      'uid': await _storage.read(key: keyUserUid),
      'phone': await _storage.read(key: keyUserPhone),
      'name': await _storage.read(key: keyUserName),
      'schoolZone': await _storage.read(key: keyUserSchoolZone),
      'schoolName': await _storage.read(key: keyUserSchoolName),
      'track': await _storage.read(key: keyUserTrack),
      'paymentStatus': await _storage.read(key: keyPaymentStatus),
    };
  }

  /// Wipes all sensitive tokens, cached PIN hashes, and user data upon Logout or Switch Account
  Future<void> clearSecureStorage() async {
    await _storage.deleteAll();
  }
}

/// Snapshot of lockout state
class LockoutStatus {
  final bool isLocked;
  final int remainingSeconds;
  final int failedAttempts;
  final bool requiresOnlineRecovery;

  const LockoutStatus({
    required this.isLocked,
    required this.remainingSeconds,
    required this.failedAttempts,
    required this.requiresOnlineRecovery,
  });
}
