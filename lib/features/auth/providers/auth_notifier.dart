import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';
import '../models/payment_status.dart';
import '../models/student_track.dart';
import '../services/auth_service.dart';
import '../services/pin_offline_service.dart';
import 'auth_state.dart';

// Storage keys for persistent preferences
class AuthStorageKeys {
  static const String studentTrack = 'selected_student_track';
  static const String isOnboarded = 'user_is_onboarded';
  static const String userUid = 'auth_user_uid';
  static const String userPhone = 'auth_user_phone';
  static const String userFullName = 'auth_user_full_name';
  static const String userSchoolName = 'auth_user_school_name';
  static const String userZoneName = 'auth_user_zone_name';
  static const String isGuest = 'auth_is_guest';
  static const String paymentStatus = 'auth_payment_status';
  static const String paymentReceiptUrl = 'auth_payment_receipt_url';
  static const String amountPaid = 'auth_amount_paid';
}

/// Provider for PinOfflineService
final pinOfflineServiceProvider = Provider<PinOfflineService>((ref) {
  return PinOfflineService();
});

/// Provider for the AuthService interface
final authServiceProvider = Provider<IAuthService>((ref) {
  final pinOffline = ref.watch(pinOfflineServiceProvider);
  return FirebaseAuthService(pinOfflineService: pinOffline);
});

/// StateNotifierProvider for managing global authentication & onboarding flow
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final pinOffline = ref.watch(pinOfflineServiceProvider);
  return AuthNotifier(authService, pinOffline);
});

/// Convenience provider for checking if user is fully logged in and onboarded
final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(authNotifierProvider);
  return state is AuthenticatedState;
});

/// Convenience provider for checking if onboarding profile & track setup is complete
final isOnboardedProvider = Provider<bool>((ref) {
  final state = ref.watch(authNotifierProvider);
  if (state is AuthenticatedState) {
    return state.isOnboarded;
  }
  return false;
});

/// Convenience provider for accessing current authenticated user profile
final currentUserProvider = Provider<AuthUser?>((ref) {
  final state = ref.watch(authNotifierProvider);
  if (state is AuthenticatedState) {
    return state.user;
  }
  return null;
});

/// Crucial provider exposing the selected StudentTrack across the app
final studentTrackProvider = Provider<StudentTrack>((ref) {
  final state = ref.watch(authNotifierProvider);
  if (state is AuthenticatedState) {
    return state.track;
  }
  return StudentTrack.both;
});

/// Dynamic feature flags for Dashboard
final shouldShowIfaBoruProvider = Provider<bool>((ref) {
  final track = ref.watch(studentTrackProvider);
  return track == StudentTrack.ifaBoruOnly || track == StudentTrack.both;
});

final shouldShowMinistryProvider = Provider<bool>((ref) {
  final track = ref.watch(studentTrackProvider);
  return track == StudentTrack.ministryOnly || track == StudentTrack.both;
});

/// Exposes the student's payment verification status (PENDING, VERIFIED, REJECTED)
final paymentStatusProvider = Provider<PaymentStatus>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.paymentStatus ?? PaymentStatus.pending;
});

/// Convenience provider: true only when payment has been reviewed & verified by backend
final isPaymentVerifiedProvider = Provider<bool>((ref) {
  final status = ref.watch(paymentStatusProvider);
  return status == PaymentStatus.verified;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthService _authService;
  final PinOfflineService _pinOfflineService;

  AuthNotifier(this._authService, this._pinOfflineService) : super(const AuthInitial()) {
    checkInitialSession();
  }

  /// Automatically check if user has a stored PIN hash or active session
  Future<void> checkInitialSession() async {
    try {
      final hasPin = await _pinOfflineService.hasConfiguredPin();
      if (hasPin) {
        final profile = await _pinOfflineService.getUserProfile();
        final lockout = await _pinOfflineService.getLockoutStatus();
        final phone = profile['phone'] ?? '';
        final name = profile['name'];

        state = AuthPinRequiredState(
          studentName: name,
          phoneNumber: phone,
          isLocked: lockout.isLocked,
          remainingLockoutSeconds: lockout.remainingSeconds,
          failedAttempts: lockout.failedAttempts,
          requiresOnlineRecovery: lockout.requiresOnlineRecovery,
        );
        return;
      }

      // Check SharedPreferences for guest session fallback
      final prefs = await SharedPreferences.getInstance();
      final isGuestSession = prefs.getBool(AuthStorageKeys.isGuest) ?? false;
      if (isGuestSession) {
        final savedTrack = StudentTrack.fromStorageValue(prefs.getString(AuthStorageKeys.studentTrack));
        final guestUser = AuthUser(
          uid: prefs.getString(AuthStorageKeys.userUid) ?? 'offline_guest',
          phoneNumber: prefs.getString(AuthStorageKeys.userPhone) ?? 'Offline Guest',
          fullName: prefs.getString(AuthStorageKeys.userFullName) ?? 'Barataa Kutaa 8ffaa',
          schoolName: prefs.getString(AuthStorageKeys.userSchoolName),
          zoneName: prefs.getString(AuthStorageKeys.userZoneName) ?? 'Oromiyaa',
          isVerified: false,
          paymentStatus: PaymentStatus.verified,
          selectedTrack: savedTrack,
        );
        state = AuthenticatedState(
          user: guestUser,
          track: savedTrack,
          isOfflineSession: true,
          isOnboarded: true,
        );
        return;
      }

      state = const UnauthenticatedState();
    } catch (_) {
      state = const UnauthenticatedState();
    }
  }

  /// Daily Offline Unlock: Verifies 6-digit PIN against local PBKDF2 salted hash
  Future<bool> verifyOfflinePin(String pin) async {
    final cur = state is AuthPinRequiredState ? (state as AuthPinRequiredState) : null;
    final lockout = await _pinOfflineService.getLockoutStatus();
    if (lockout.isLocked) {
      state = AuthPinRequiredState(
        phoneNumber: cur?.phoneNumber ?? '',
        studentName: cur?.studentName,
        isLocked: true,
        remainingLockoutSeconds: lockout.remainingSeconds,
        failedAttempts: lockout.failedAttempts,
        requiresOnlineRecovery: lockout.requiresOnlineRecovery,
      );
      return false;
    }

    final isValid = await _pinOfflineService.verifyOfflinePin(pin);

    if (isValid) {
      await _pinOfflineService.resetLockoutOnSuccess();
      final profile = await _pinOfflineService.getUserProfile();
      final token = await _pinOfflineService.getAccessToken();
      final track = StudentTrack.fromStorageValue(profile['track']);
      final remainingGraceDays = await _pinOfflineService.getRemainingGraceDays();
      final isGraceExpired = await _pinOfflineService.isGracePeriodExpired();

      final user = AuthUser(
        uid: profile['uid'] ?? 'local_user',
        phoneNumber: profile['phone'] ?? '',
        fullName: profile['name'],
        schoolName: profile['schoolName'],
        zoneName: profile['schoolZone'],
        backendToken: token,
        isVerified: true,
        paymentStatus: PaymentStatus.fromString(profile['paymentStatus']),
        selectedTrack: track,
      );

      state = AuthenticatedState(
        user: user,
        track: track,
        isOfflineSession: true,
        isOnboarded: true,
        graceDaysRemaining: remainingGraceDays,
        isGraceExpired: isGraceExpired,
      );
      return true;
    } else {
      final updatedLockout = await _pinOfflineService.recordFailedPinAttempt();
      final curPinState = state is AuthPinRequiredState ? (state as AuthPinRequiredState) : null;

      state = AuthPinRequiredState(
        phoneNumber: curPinState?.phoneNumber ?? '',
        studentName: curPinState?.studentName,
        isLocked: updatedLockout.isLocked,
        remainingLockoutSeconds: updatedLockout.remainingSeconds,
        failedAttempts: updatedLockout.failedAttempts,
        requiresOnlineRecovery: updatedLockout.requiresOnlineRecovery,
      );
      return false;
    }
  }

  /// Signup Once Online: Registers student account and sets up local offline PIN
  Future<bool> signupWithPin({
    required String name,
    required String phone,
    required String schoolZone,
    String? schoolName,
    required StudentTrack track,
    required String pin,
    String? otpCode,
  }) async {
    state = const AuthLoading(message: "Herregni keessan tolfamaa jira...");

    try {
      final user = await _authService.signupWithPin(
        name: name,
        phone: phone,
        schoolZone: schoolZone,
        schoolName: schoolName,
        track: track,
        pin: pin,
        otpCode: otpCode,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AuthStorageKeys.studentTrack, track.storageValue);
      await prefs.setBool(AuthStorageKeys.isOnboarded, true);

      state = AuthenticatedState(
        user: user,
        track: track,
        isOfflineSession: false,
        isOnboarded: true,
        graceDaysRemaining: 21,
      );
      return true;
    } on AuthException catch (e) {
      state = AuthErrorState(
        errorMessageOm: e.message,
        technicalError: e.code,
      );
      return false;
    } catch (e) {
      state = AuthErrorState(
        errorMessageOm: "Dogoggorri galmee mudateera. Intarneetii keessan ilaalaa.",
        technicalError: e.toString(),
      );
      return false;
    }
  }

  /// Online Login (New phone or reinstall)
  Future<bool> loginOnline({
    required String phone,
    required String pin,
  }) async {
    state = const AuthLoading(message: "Seensaan mirkanaa'aa jira...");

    try {
      final user = await _authService.loginWithPin(phone: phone, pin: pin);
      final track = user.selectedTrack ?? StudentTrack.both;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AuthStorageKeys.studentTrack, track.storageValue);
      await prefs.setBool(AuthStorageKeys.isOnboarded, true);

      state = AuthenticatedState(
        user: user,
        track: track,
        isOfflineSession: false,
        isOnboarded: true,
        graceDaysRemaining: 21,
      );
      return true;
    } on AuthException catch (e) {
      state = AuthErrorState(
        errorMessageOm: e.message,
        technicalError: e.code,
      );
      return false;
    } catch (e) {
      state = AuthErrorState(
        errorMessageOm: "Seensi hin milkoofne. Sarara intarneetii ykn PIN mirkaneeffadhaa.",
        technicalError: e.toString(),
      );
      return false;
    }
  }

  /// Reset PIN using single-use 15-minute temporary code from school admin
  Future<bool> resetPinWithCode({
    required String phone,
    required String resetCode,
    required String newPin,
  }) async {
    state = const AuthLoading(message: "PIN haaraan galmaa'aa jira...");

    try {
      final success = await _authService.resetPinWithCode(
        phone: phone,
        resetCode: resetCode,
        newPin: newPin,
      );

      if (success) {
        state = AuthPinRequiredState(
          phoneNumber: phone,
          isLocked: false,
          remainingLockoutSeconds: 0,
          failedAttempts: 0,
          requiresOnlineRecovery: false,
        );
        return true;
      }
      return false;
    } on AuthException catch (e) {
      state = AuthErrorState(
        errorMessageOm: e.message,
        technicalError: e.code,
      );
      return false;
    } catch (e) {
      state = AuthErrorState(
        errorMessageOm: "Deebisaan PIN hin milkoofne. Irra deebi'aa yaalaa.",
        technicalError: e.toString(),
      );
      return false;
    }
  }

  /// In-App PIN Change
  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final s = state;
    if (s is! AuthenticatedState) return false;
    final currentUser = s.user;

    state = const AuthLoading(message: "PIN jijjiiramaa jira...");

    try {
      final success = await _authService.changePin(
        phone: currentUser.phoneNumber,
        currentPin: currentPin,
        newPin: newPin,
      );
      if (success) {
        state = s.copyWith();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      state = AuthErrorState(errorMessageOm: e.message, technicalError: e.code);
      return false;
    } catch (e) {
      state = AuthErrorState(errorMessageOm: "Jijjiirraan PIN hin milkoofne: $e");
      return false;
    }
  }

  /// Secure Account Deletion: Requires PIN verification
  Future<bool> deleteAccount({required String pin}) async {
    final s = state;
    if (s is! AuthenticatedState) return false;
    final currentUser = s.user;

    state = const AuthLoading(message: "Herregni keessan haqamaa jira...");

    try {
      final success = await _authService.deleteAccount(
        phone: currentUser.phoneNumber,
        pin: pin,
      );

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        state = const UnauthenticatedState();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      state = AuthErrorState(errorMessageOm: e.message, technicalError: e.code);
      return false;
    } catch (e) {
      state = AuthErrorState(errorMessageOm: "Haqiinsi herregaa hin milkoofne: $e");
      return false;
    }
  }

  /// Record submitted payment receipt with PENDING status (preserves payment workflow)
  Future<void> recordPaymentSubmitted({
    required StudentTrack track,
    required String fullName,
    required String schoolName,
    required String zoneName,
    String? receiptUrl,
    double? amountPaid,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AuthStorageKeys.studentTrack, track.storageValue);
      await prefs.setBool(AuthStorageKeys.isOnboarded, true);
      await prefs.setString(AuthStorageKeys.userFullName, fullName.trim());
      await prefs.setString(AuthStorageKeys.userSchoolName, schoolName.trim());
      await prefs.setString(AuthStorageKeys.userZoneName, zoneName.trim());
      await prefs.setString(AuthStorageKeys.paymentStatus, PaymentStatus.pending.prismaValue);
      if (receiptUrl != null) {
        await prefs.setString(AuthStorageKeys.paymentReceiptUrl, receiptUrl);
      }
      if (amountPaid != null) {
        await prefs.setDouble(AuthStorageKeys.amountPaid, amountPaid);
      }

      String uid = prefs.getString(AuthStorageKeys.userUid) ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
      String phone = prefs.getString(AuthStorageKeys.userPhone) ?? '+251';

      final s = state;
      if (s is AuthenticatedState) {
        uid = s.user.uid;
        phone = s.user.phoneNumber;
      }

      final updatedUser = AuthUser(
        uid: uid,
        phoneNumber: phone,
        fullName: fullName.trim(),
        schoolName: schoolName.trim(),
        zoneName: zoneName.trim(),
        isVerified: true,
        paymentStatus: PaymentStatus.pending,
        selectedTrack: track,
        paymentReceiptUrl: receiptUrl,
        amountPaid: amountPaid,
        createdAt: DateTime.now(),
      );

      state = AuthenticatedState(
        user: updatedUser,
        track: track,
        isOfflineSession: false,
        isOnboarded: true,
      );
    } catch (e) {
      debugPrint('Error recording payment: $e');
    }
  }

  /// Switch account for shared phones: Clears secure storage and shows login screen
  Future<void> switchAccount() async {
    await _pinOfflineService.clearSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthStorageKeys.isOnboarded);
    await prefs.remove(AuthStorageKeys.userUid);
    state = const UnauthenticatedState();
  }

  /// Log out and clear state
  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _pinOfflineService.clearSecureStorage();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AuthStorageKeys.isOnboarded);
      await prefs.remove(AuthStorageKeys.userUid);
      await prefs.remove(AuthStorageKeys.isGuest);
      await _authService.signOut();
      state = const UnauthenticatedState();
    } catch (_) {
      state = const UnauthenticatedState();
    }
  }

  void clearError() {
    if (state is AuthErrorState) {
      checkInitialSession();
    }
  }

  // Legacy stubs for existing tests and components
  Future<void> saveProfileAndTrack({
    required String fullName,
    required String schoolName,
    required String zoneName,
    required StudentTrack track,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthStorageKeys.studentTrack, track.storageValue);
    await prefs.setBool(AuthStorageKeys.isOnboarded, true);

    if (state is AuthenticatedState) {
      final cur = state as AuthenticatedState;
      state = cur.copyWith(
        track: track,
        user: cur.user.copyWith(
          fullName: fullName,
          schoolName: schoolName,
          zoneName: zoneName,
          selectedTrack: track,
        ),
      );
    }
  }

  Future<void> updatePaymentStatus(PaymentStatus newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthStorageKeys.paymentStatus, newStatus.prismaValue);

    final currentState = state;
    if (currentState is AuthenticatedState) {
      final updatedUser = currentState.user.copyWith(paymentStatus: newStatus);
      state = currentState.copyWith(user: updatedUser);
    }
  }

  Future<void> continueAsGuest({
    String fullName = "Barataa Kutaa 8ffaa (Offline)",
    String zoneName = "Oromiyaa",
    String schoolName = "Mana Barumsaa Sad. 1ffaa",
    StudentTrack track = StudentTrack.both,
  }) async {
    state = const AuthLoading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final guestUid = 'guest_local_${DateTime.now().millisecondsSinceEpoch}';

      await prefs.setBool(AuthStorageKeys.isGuest, true);
      await prefs.setBool(AuthStorageKeys.isOnboarded, true);
      await prefs.setString(AuthStorageKeys.userUid, guestUid);
      await prefs.setString(AuthStorageKeys.userPhone, "Offline Guest");
      await prefs.setString(AuthStorageKeys.userFullName, fullName);
      await prefs.setString(AuthStorageKeys.userZoneName, zoneName);
      await prefs.setString(AuthStorageKeys.userSchoolName, schoolName);
      await prefs.setString(AuthStorageKeys.studentTrack, track.storageValue);

      final guestUser = AuthUser(
        uid: guestUid,
        phoneNumber: "Offline Guest",
        fullName: fullName,
        schoolName: schoolName,
        zoneName: zoneName,
        isVerified: true,
        paymentStatus: PaymentStatus.verified,
      );

      state = AuthenticatedState(
        user: guestUser,
        track: track,
        isOfflineSession: true,
        isOnboarded: true,
      );
    } catch (e) {
      state = AuthErrorState(
        errorMessageOm: "Seensi sarara-malee hin milkoofne.",
        technicalError: e.toString(),
      );
    }
  }
}
