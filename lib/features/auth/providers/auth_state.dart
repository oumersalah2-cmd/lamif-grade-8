import '../models/auth_user.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});
}

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

class AuthenticatedState extends AuthState {
  final AuthUser user;
  final bool isOfflineSession;

  const AuthenticatedState({
    required this.user,
    this.isOfflineSession = false,
  });
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthErrorState extends AuthState {
  final String errorMessageOm;
  final String? technicalError;

  const AuthErrorState({
    required this.errorMessageOm,
    this.technicalError,
  });
}
