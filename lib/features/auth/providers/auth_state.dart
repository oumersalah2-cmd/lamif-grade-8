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

/// In-flight operation (sending OTP, verifying, saving profile)
class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});
}

/// Firebase OTP was successfully dispatched to user's phone
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

  const AuthenticatedState({
    required this.user,
    required this.track,
    this.isOfflineSession = false,
    this.isOnboarded = true,
  });

  AuthenticatedState copyWith({
    AuthUser? user,
    StudentTrack? track,
    bool? isOfflineSession,
    bool? isOnboarded,
  }) {
    return AuthenticatedState(
      user: user ?? this.user,
      track: track ?? this.track,
      isOfflineSession: isOfflineSession ?? this.isOfflineSession,
      isOnboarded: isOnboarded ?? this.isOnboarded,
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
