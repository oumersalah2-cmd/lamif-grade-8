import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

/// Provider for the AuthService interface
final authServiceProvider = Provider<IAuthService>((ref) {
  return FirebaseAuthService();
});

/// StateNotifierProvider for managing global authentication state
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Convenience provider for checking if user is logged in
final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(authNotifierProvider);
  return state is AuthenticatedState;
});

/// Convenience provider for accessing current authenticated user
final currentUserProvider = Provider<AuthUser?>((ref) {
  final state = ref.watch(authNotifierProvider);
  if (state is AuthenticatedState) {
    return state.user;
  }
  return null;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthService _authService;

  AuthNotifier(this._authService) : super(const AuthInitial()) {
    checkInitialSession();
  }

  /// Automatically check if user was already signed in
  Future<void> checkInitialSession() async {
    try {
      final user = await _authService.restoreSession();
      if (user != null) {
        state = AuthenticatedState(user: user);
      } else {
        state = const UnauthenticatedState();
      }
    } catch (_) {
      state = const UnauthenticatedState();
    }
  }

  /// Send Phone OTP via Firebase Auth
  Future<void> sendOtp(String rawPhoneNumber) async {
    final formattedPhone = rawPhoneNumber.trim().startsWith('+')
        ? rawPhoneNumber.trim()
        : '+251${rawPhoneNumber.trim().replaceFirst(RegExp(r'^0'), '')}';

    state = const AuthLoading(message: "Koodiin OTP gara bilbila keessaniitti ergamaa jira...");

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
            await verifyOtp(
              smsCode: credential.smsCode!,
              fullName: "Barataa Kutaa 8ffaa",
            );
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

  /// Verify entered OTP code and bridge to Express/Prisma backend
  Future<void> verifyOtp({
    required String smsCode,
    String? fullName,
    String? schoolName,
    String? zoneName,
  }) async {
    final currentState = state;
    if (currentState is! OtpSentState) {
      state = const AuthErrorState(
        errorMessageOm: "Dursa lakkoofsa bilbilaatiin OTP gaafadhaa.",
      );
      return;
    }

    state = const AuthLoading(message: "Koodiin OTP mirkanaa'aa jira...");

    try {
      final user = await _authService.verifyOtpAndLogin(
        verificationId: currentState.verificationId,
        smsCode: smsCode.trim(),
        fullName: fullName,
        schoolName: schoolName,
        zoneName: zoneName,
      );

      state = AuthenticatedState(user: user);
    } on FirebaseAuthException catch (e) {
      state = AuthErrorState(
        errorMessageOm: _mapFirebaseErrorToAfaanOromo(e),
        technicalError: e.message,
      );
    } catch (e) {
      state = AuthErrorState(
        errorMessageOm: "Koodii sirrii hin taane ykn yeroon isaa darbeera.",
        technicalError: e.toString(),
      );
    }
  }

  /// Guest Mode: Allows immediate offline access for students without SIM/Internet
  void continueAsGuest({
    String fullName = "Barataa Kutaa 8ffaa (Offline)",
    String zoneName = "Oromiyaa",
  }) {
    state = AuthenticatedState(
      user: AuthUser(
        uid: "guest_local_${DateTime.now().millisecondsSinceEpoch}",
        phoneNumber: "Offline Guest",
        fullName: fullName,
        zoneName: zoneName,
        isVerified: false,
      ),
      isOfflineSession: true,
    );
  }

  /// Log out
  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _authService.signOut();
      state = const UnauthenticatedState();
    } catch (e) {
      state = const UnauthenticatedState();
    }
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
