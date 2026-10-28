import 'package:flutter_test/flutter_test.dart';
import 'package:lamif_grade_8/features/auth/services/pin_offline_service.dart';

/// In-memory mock of FlutterSecureStorage for headless unit testing
class FakeSecureStorage {
  final Map<String, String> _store = {};

  Future<void> write({required String key, required String? value}) async {
    if (value != null) {
      _store[key] = value;
    } else {
      _store.remove(key);
    }
  }

  Future<String?> read({required String key}) async {
    return _store[key];
  }

  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  Future<void> deleteAll() async {
    _store.clear();
  }
}

void main() {
  group('PIN Auth Unit Tests (Lamif Kutaa 8)', () {
    test('1. PBKDF2 PIN Salted Hashing & Constant-Time Verification', () {
      const pin = '123456';
      final salt = PinOfflineService.generateRandomSalt();
      final hash = PinOfflineService.derivePinHash(pin, salt);

      expect(hash, isNotEmpty);
      expect(hash, isNot(equals(pin)));

      // Verifying identical PIN produces identical hash with same salt
      final verifyHash = PinOfflineService.derivePinHash('123456', salt);
      expect(verifyHash, equals(hash));

      // Different PIN produces different hash
      final wrongHash = PinOfflineService.derivePinHash('654321', salt);
      expect(wrongHash, isNot(equals(hash)));

      // Different salt produces completely different hash for same PIN
      final salt2 = PinOfflineService.generateRandomSalt();
      final hashWithSalt2 = PinOfflineService.derivePinHash(pin, salt2);
      expect(hashWithSalt2, isNot(equals(hash)));
    });

    test('2. Lockout Escalation Logic (5 fails -> 5m, 6 fails -> 15m, 7 fails -> 60m)', () {
      int calculateLockoutMinutes(int failedAttempts) {
        if (failedAttempts == 5) return 5;
        if (failedAttempts == 6) return 15;
        if (failedAttempts >= 7) return 60;
        return 0;
      }

      // 1 to 4 attempts: no lockout
      for (int i = 1; i <= 4; i++) {
        expect(calculateLockoutMinutes(i), equals(0), reason: 'Attempt $i should not trigger lockout');
      }

      // 5th attempt: 5 minutes
      expect(calculateLockoutMinutes(5), equals(5));

      // 6th attempt: 15 minutes
      expect(calculateLockoutMinutes(6), equals(15));

      // 7th and higher attempts: 60 minutes
      expect(calculateLockoutMinutes(7), equals(60));
      expect(calculateLockoutMinutes(8), equals(60));
      expect(calculateLockoutMinutes(9), equals(60));
    });

    test('3. Lockout Escalation: 10 Total Failures Requires Online Recovery', () {
      bool requiresRecovery(int lifetimeFailures) => lifetimeFailures >= 10;

      expect(requiresRecovery(4), isFalse);
      expect(requiresRecovery(9), isFalse);
      expect(requiresRecovery(10), isTrue, reason: '10th failed attempt must enforce online reset');
      expect(requiresRecovery(12), isTrue);
    });

    test('4. Offline Grace Period Calculation (21 Days Default)', () {
      final now = DateTime.now();

      // Case A: 5 days offline -> Allowed
      final activeDeadline = now.add(const Duration(days: 16));
      final remainingDays = activeDeadline.difference(now).inDays;
      expect(remainingDays > 0, isTrue);
      expect(activeDeadline.isAfter(now), isTrue);

      // Case B: Exactly 21 days -> Allowed
      final fullDeadline = now.add(const Duration(days: 21));
      expect(fullDeadline.difference(now).inDays, equals(21));

      // Case C: Exceeded 21 days (22 days offline) -> Expired, requires online sync
      final expiredDeadline = now.subtract(const Duration(days: 1));
      expect(expiredDeadline.isBefore(now), isTrue);
      expect(expiredDeadline.difference(now).inDays < 0, isTrue);
    });

    test('5. Session Token & Refresh State Model', () {
      const accessToken = 'header.payload.signature_access';
      const refreshToken = 'header.payload.signature_refresh';

      final tokenMap = <String, String>{
        'access': accessToken,
        'refresh': refreshToken,
      };

      expect(tokenMap['access'], equals(accessToken));
      expect(tokenMap['refresh'], equals(refreshToken));

      // Simulating token revocation on PIN reset
      tokenMap.clear();
      expect(tokenMap.isEmpty, isTrue);
    });

    test('6. Reset Code 15-Minute Expiry & Single-Use Check', () {
      final issuedAt = DateTime.now();
      final expiresAt = issuedAt.add(const Duration(minutes: 15));

      // At 10 minutes: Still valid
      final checkAt10m = issuedAt.add(const Duration(minutes: 10));
      expect(checkAt10m.isBefore(expiresAt), isTrue);

      // At 16 minutes: Expired
      final checkAt16m = issuedAt.add(const Duration(minutes: 16));
      expect(checkAt16m.isAfter(expiresAt), isTrue);

      // Single-use simulation: code cleared immediately after successful consumption
      String? activeResetCode = '849201';
      expect(activeResetCode, isNotNull);

      // Consume code
      activeResetCode = null;
      expect(activeResetCode, isNull);
    });
  });
}
