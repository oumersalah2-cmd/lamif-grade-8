import '../models/auth_user.dart';
import '../models/student_track.dart';

/// Base state for Authentication & Onboarding
abstract class AuthState {
  const AuthState();
}

/// Initializing or checking local session from storage
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// In-flight operation (login, register, verifying, saving profile)
class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});
}

/// Device has a stored account & PIN hash; user must enter 6-digit PIN to unlock
class AuthPinRequiredState extends AuthState {
  final String? studentName;
  final String phoneNumber;
  final bool isLocked;
  final int remainingLockoutSeconds;
  final int failedAttempts;
  final bool requiresOnlineRecovery;

  const AuthPinRequiredState({
    this.studentName,
    required this.phoneNumber,
    this.isLocked = false,
    this.remainingLockoutSeconds = 0,
    this.failedAttempts = 0,
    this.requiresOnlineRecovery = false,
  });

  AuthPinRequiredState copyWith({
    String? studentName,
    String? phoneNumber,
    bool? isLocked,
    int? remainingLockoutSeconds,
    int? failedAttempts,
    bool? requiresOnlineRecovery,
  }) {
    return AuthPinRequiredState(
      studentName: studentName ?? this.studentName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLocked: isLocked ?? this.isLocked,
      remainingLockoutSeconds: remainingLockoutSeconds ?? this.remainingLockoutSeconds,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      requiresOnlineRecovery: requiresOnlineRecovery ?? this.requiresOnlineRecovery,
    );
  }
}

/// OTP was dispatched to user's phone (used only when REQUIRE_PHONE_OTP_AT_SIGNUP=true)
class OtpSentState extends AuthState {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  const OtpSentState({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });
}

/// Phone authentication completed, user needs to pick Track and enter Profile
class OtpVerifiedState extends AuthState {
  final String uid;
  final String phoneNumber;
  final String? existingFullName;
  final String? existingSchool;
  final String? existingZone;

  const OtpVerifiedState({
    required this.uid,
    required this.phoneNumber,
    this.existingFullName,
    this.existingSchool,
    this.existingZone,
  });
}

/// User is fully authenticated, onboarded, and has an active track selected
class AuthenticatedState extends AuthState {
  final AuthUser user;
  final StudentTrack track;
  final bool isOfflineSession;
  final bool isOnboarded;
  final bool mustSetPin;
  final int graceDaysRemaining;
  final bool isGraceExpired;

  const AuthenticatedState({
    required this.user,
    required this.track,
    this.isOfflineSession = false,
    this.isOnboarded = true,
    this.mustSetPin = false,
    this.graceDaysRemaining = 21,
    this.isGraceExpired = false,
  });

  AuthenticatedState copyWith({
    AuthUser? user,
    StudentTrack? track,
    bool? isOfflineSession,
    bool? isOnboarded,
    bool? mustSetPin,
    int? graceDaysRemaining,
    bool? isGraceExpired,
  }) {
    return AuthenticatedState(
      user: user ?? this.user,
      track: track ?? this.track,
      isOfflineSession: isOfflineSession ?? this.isOfflineSession,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      mustSetPin: mustSetPin ?? this.mustSetPin,
      graceDaysRemaining: graceDaysRemaining ?? this.graceDaysRemaining,
      isGraceExpired: isGraceExpired ?? this.isGraceExpired,
    );
  }
}

/// User is logged out or initial launch without saved credentials
class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

/// Error encountered during authentication or onboarding
class AuthErrorState extends AuthState {
  final String errorMessageOm;
  final String? technicalError;

  const AuthErrorState({
    required this.errorMessageOm,
    this.technicalError,
  });
}
