import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';
import '../models/student_track.dart';
import '../services/auth_service.dart';
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
}

/// Provider for the AuthService interface
final authServiceProvider = Provider<IAuthService>((ref) {
  return FirebaseAuthService();
});

/// StateNotifierProvider for managing global authentication & onboarding flow
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
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
  return StudentTrack.both; // Default academic fallback
});

/// Dynamic feature flag for Dashboard to hide or show "Ifa Boru" specific exam modules
final shouldShowIfaBoruProvider = Provider<bool>((ref) {
  final track = ref.watch(studentTrackProvider);
  return track == StudentTrack.ifaBoruOnly || track == StudentTrack.both;
});

/// Dynamic feature flag for Dashboard to hide or show "Ministry Exam" specific modules
final shouldShowMinistryProvider = Provider<bool>((ref) {
  final track = ref.watch(studentTrackProvider);
  return track == StudentTrack.ministryOnly || track == StudentTrack.both;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthService _authService;

  AuthNotifier(this._authService) : super(const AuthInitial()) {
    checkInitialSession();
  }

  /// Automatically check if user was already signed in and restore chosen track
  Future<void> checkInitialSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isOnboarded = prefs.getBool(AuthStorageKeys.isOnboarded) ?? false;
      final savedTrackStr = prefs.getString(AuthStorageKeys.studentTrack);
      final savedTrack = StudentTrack.fromStorageValue(savedTrackStr);

      final isGuestSession = prefs.getBool(AuthStorageKeys.isGuest) ?? false;
      if (isGuestSession && isOnboarded) {
        final guestUser = AuthUser(
          uid: prefs.getString(AuthStorageKeys.userUid) ?? 'offline_guest',
          phoneNumber: prefs.getString(AuthStorageKeys.userPhone) ?? 'Offline Guest',
          fullName: prefs.getString(AuthStorageKeys.userFullName) ?? 'Barataa Kutaa 8ffaa',
          schoolName: prefs.getString(AuthStorageKeys.userSchoolName),
          zoneName: prefs.getString(AuthStorageKeys.userZoneName) ?? 'Oromiyaa',
          isVerified: false,
        );
        state = AuthenticatedState(
          user: guestUser,
          track: savedTrack,
          isOfflineSession: true,
          isOnboarded: true,
        );
        return;
      }

      // Check Firebase session
      final firebaseUser = await _authService.restoreSession();
      if (firebaseUser != null) {
        if (isOnboarded) {
          final enrichedUser = firebaseUser.copyWith(
            fullName: prefs.getString(AuthStorageKeys.userFullName) ?? firebaseUser.fullName,
            schoolName: prefs.getString(AuthStorageKeys.userSchoolName) ?? firebaseUser.schoolName,
            zoneName: prefs.getString(AuthStorageKeys.userZoneName) ?? firebaseUser.zoneName,
          );
          state = AuthenticatedState(
            user: enrichedUser,
            track: savedTrack,
            isOfflineSession: false,
            isOnboarded: true,
          );
        } else {
          // Phone is verified but needs profile & track selection
          state = OtpVerifiedState(
            uid: firebaseUser.uid,
            phoneNumber: firebaseUser.phoneNumber,
            existingFullName: prefs.getString(AuthStorageKeys.userFullName),
            existingSchool: prefs.getString(AuthStorageKeys.userSchoolName),
            existingZone: prefs.getString(AuthStorageKeys.userZoneName),
          );
        }
      } else {
        state = const UnauthenticatedState();
      }
    } catch (_) {
      state = const UnauthenticatedState();
    }
  }

  /// Send Phone OTP via Firebase Auth
  Future<void> sendOtp(String rawPhoneNumber) async {
    final cleaned = rawPhoneNumber.trim().replaceAll(' ', '');
    final formattedPhone = cleaned.startsWith('+')
        ? cleaned
        : '+251${cleaned.replaceFirst(RegExp(r'^0'), '')}';

    state = const AuthLoading(message: "Koodiin OTP bilbila keessaniitti ergamaa jira...");

    try {
      await _authService.sendOtp(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId, resendToken) {
          state = OtpSentState(
            verificationId: verificationId,
            phoneNumber: formattedPhone,
            resendToken: resendToken,
          );
        },
        onVerificationFailed: (FirebaseAuthException e) {
          final errorMsg = _mapFirebaseErrorToAfaanOromo(e);
          state = AuthErrorState(
            errorMessageOm: errorMsg,
            technicalError: e.message,
          );
        },
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          // Instant auto-verification (Android SMS Retriever API)
          if (credential.smsCode != null && state is OtpSentState) {
            await verifyOtp(smsCode: credential.smsCode!);
          }
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          // Timeout occurred; user can still manually enter SMS code
        },
      );
    } catch (e) {
      state = AuthErrorState(
        errorMessageOm: "Ergamuun OTP hin milkoofne. Sarara intarneetii ykn bilbilaa mirkaneeffadhaa.",
        technicalError: e.toString(),
      );
    }
  }

  /// Verify entered OTP code and transition to Track Selection / Profile Setup
  Future<bool> verifyOtp({
    required String smsCode,
    String? fullName,
    String? schoolName,
    String? zoneName,
  }) async {
    final currentState = state;
    if (currentState is! OtpSentState) {
      state = const AuthErrorState(
        errorMessageOm: "Dursa lakkoofsa bilbilaatiin koodii gaafadhaa.",
      );
      return false;
    }

    state = const AuthLoading(message: "Koodiin mirkanaa'aa jira...");

    try {
      final user = await _authService.verifyOtpAndLogin(
        verificationId: currentState.verificationId,
        smsCode: smsCode.trim(),
        fullName: fullName,
        schoolName: schoolName,
        zoneName: zoneName,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AuthStorageKeys.userUid, user.uid);
      await prefs.setString(AuthStorageKeys.userPhone, user.phoneNumber);

      final isOnboarded = prefs.getBool(AuthStorageKeys.isOnboarded) ?? false;
      final savedTrackStr = prefs.getString(AuthStorageKeys.studentTrack);

      if (isOnboarded && savedTrackStr != null) {
        state = AuthenticatedState(
          user: user.copyWith(
            fullName: fullName ?? prefs.getString(AuthStorageKeys.userFullName),
            schoolName: schoolName ?? prefs.getString(AuthStorageKeys.userSchoolName),
            zoneName: zoneName ?? prefs.getString(AuthStorageKeys.userZoneName),
          ),
          track: StudentTrack.fromStorageValue(savedTrackStr),
          isOnboarded: true,
        );
      } else {
        // Transition to Profile & Track Selection Screen
        state = OtpVerifiedState(
          uid: user.uid,
          phoneNumber: user.phoneNumber,
          existingFullName: fullName ?? prefs.getString(AuthStorageKeys.userFullName),
          existingSchool: schoolName ?? prefs.getString(AuthStorageKeys.userSchoolName),
          existingZone: zoneName ?? prefs.getString(AuthStorageKeys.userZoneName),
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthErrorState(
        errorMessageOm: _mapFirebaseErrorToAfaanOromo(e),
        technicalError: e.message,
      );
      return false;
    } catch (e) {
      state = AuthErrorState(
        errorMessageOm: "Koodii sirrii hin taane ykn yeroon isaa darbeera.",
        technicalError: e.toString(),
      );
      return false;
    }
  }

  /// Store user profile and crucial studentTrack enum to local storage
  Future<void> saveProfileAndTrack({
    required String fullName,
    required String schoolName,
    required String zoneName,
    required StudentTrack track,
  }) async {
    state = const AuthLoading(message: "Sagantaan filatame galmaa'aa jira...");

    try {
      final prefs = await SharedPreferences.getInstance();

      // Persist chosen track and profile data
      await prefs.setString(AuthStorageKeys.studentTrack, track.storageValue);
      await prefs.setBool(AuthStorageKeys.isOnboarded, true);
      await prefs.setString(AuthStorageKeys.userFullName, fullName.trim());
      await prefs.setString(AuthStorageKeys.userSchoolName, schoolName.trim());
      await prefs.setString(AuthStorageKeys.userZoneName, zoneName.trim());

      String uid = prefs.getString(AuthStorageKeys.userUid) ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
      String phone = prefs.getString(AuthStorageKeys.userPhone) ?? '+251';

      if (state is OtpVerifiedState) {
        final verifiedState = state as OtpVerifiedState;
        uid = verifiedState.uid;
        phone = verifiedState.phoneNumber;
      }

      final updatedUser = AuthUser(
        uid: uid,
        phoneNumber: phone,
        fullName: fullName.trim(),
        schoolName: schoolName.trim(),
        zoneName: zoneName.trim(),
        isVerified: true,
        createdAt: DateTime.now(),
      );

      state = AuthenticatedState(
        user: updatedUser,
        track: track,
        isOfflineSession: false,
        isOnboarded: true,
      );
    } catch (e) {
      state = AuthErrorState(
        errorMessageOm: "Galmeen sagantaa hin milkoofne. Irra deebi'aa yaalaa.",
        technicalError: e.toString(),
      );
    }
  }

  /// Change active track later from Settings or Dashboard header
  Future<void> updateTrack(StudentTrack newTrack) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthStorageKeys.studentTrack, newTrack.storageValue);

    final currentState = state;
    if (currentState is AuthenticatedState) {
      state = currentState.copyWith(track: newTrack);
    }
  }

  /// Guest Mode: Allows immediate offline access for students without SIM/Internet
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
        isVerified: false,
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

  /// Log out and clear state
  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AuthStorageKeys.isOnboarded);
      await prefs.remove(AuthStorageKeys.userUid);
      await prefs.remove(AuthStorageKeys.isGuest);
      // Keep student track preference so it remembers their choice on next login

      await _authService.signOut();
      state = const UnauthenticatedState();
    } catch (_) {
      state = const UnauthenticatedState();
    }
  }

  void resetToPhoneInput() {
    state = const UnauthenticatedState();
  }

  void clearError() {
    if (state is AuthErrorState) {
      state = const UnauthenticatedState();
    }
  }

  String _mapFirebaseErrorToAfaanOromo(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Lakkoofsi bilbilaa kun sirrii miti. (+251...) fayyadamaa.';
      case 'invalid-verification-code':
        return 'Koodiin OTP galftan dogoggora. Irra deebi\'aa yaalaa.';
      case 'session-expired':
        return 'Yeroon koodii OTP darbeera. Haaraa gaafadhaa.';
      case 'too-many-requests':
        return 'Yeroo baay\'ee yaaltaniittu. Xiqqoo eegaatii deebisaa yaalaa.';
      case 'network-request-failed':
        return 'Qunnamtiin intarneetii addaan citeera. Sarara keessan ilaalaa.';
      default:
        return 'Dogoggorri seensaa uumameera. Irra deebi\'aa yaalaa.';
    }
  }
}
