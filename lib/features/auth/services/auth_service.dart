import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/auth_user.dart';

/// Custom domain exceptions for authentication & network resilience
class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

class AuthTimeoutException extends AuthException {
  const AuthTimeoutException([String message = 'Yeroon qunnamtii intarneetii darbeera (Connection timed out).'])
      : super(message, code: 'TIMEOUT');
}

class AuthNetworkException extends AuthException {
  const AuthNetworkException([String message = 'Qunnamtiin sararaa addaan citeera (Network unreachable).'])
      : super(message, code: 'NETWORK_ERROR');
}

class AuthServerException extends AuthException {
  final int statusCode;
  const AuthServerException(String message, {required this.statusCode})
      : super(message, code: 'SERVER_ERROR_$statusCode');
}

/// Abstract contract for Authentication Service
abstract class IAuthService {
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
    int? resendToken,
  });

  Future<AuthUser> verifyOtpAndLogin({
    required String verificationId,
    required String smsCode,
    String? fullName,
    String? schoolName,
    String? zoneName,
  });

  Future<AuthUser?> restoreSession();

  Future<void> signOut();
}

/// Resilient, secure HTTP Client with timeout handling, auto-retries, and headers injection
class SecureAuthHttpClient {
  final http.Client _client;
  final Duration requestTimeout;
  final int maxRetries;

  SecureAuthHttpClient({
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 12),
    this.maxRetries = 2,
  }) : _client = client ?? http.Client();

  Map<String, String> _buildSecureHeaders({String? bearerToken}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Platform': 'LamifKutaa8-Mobile',
      'X-Client-Version': '1.0.0',
    };
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }
    return headers;
  }

  Future<http.Response> post({
    required Uri uri,
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        final response = await _client
            .post(
              uri,
              headers: _buildSecureHeaders(bearerToken: bearerToken),
              body: jsonEncode(body),
            )
            .timeout(requestTimeout);

        return response;
      } on SocketException catch (_) {
        if (attempts > maxRetries) {
          throw const AuthNetworkException();
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      } on TimeoutException catch (_) {
        if (attempts > maxRetries) {
          throw const AuthTimeoutException();
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      } catch (e) {
        if (attempts > maxRetries) {
          throw AuthException('Dogoggora qunnamtii: ${e.toString()}');
        }
      }
    }
  }

  void close() {
    _client.close();
  }
}

/// Implementation of IAuthService interfacing with Firebase Phone Auth and Express backend
class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _firebaseAuth;
  final SecureAuthHttpClient _secureHttpClient;
  final String _backendBaseUrl;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    SecureAuthHttpClient? secureHttpClient,
    String backendBaseUrl = 'https://api.lamifkutaa8.et', // Custom Express/Prisma endpoint
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _secureHttpClient = secureHttpClient ?? SecureAuthHttpClient(),
        _backendBaseUrl = backendBaseUrl;

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      forceResendingToken: resendToken,
    );
  }

  @override
  Future<AuthUser> verifyOtpAndLogin({
    required String verificationId,
    required String smsCode,
    String? fullName,
    String? schoolName,
    String? zoneName,
  }) async {
    // 1. Authenticate with Firebase using PhoneAuthProvider credential
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw const AuthException('Eenyummaan fayyadamaa Firebase keessaa hin argamne.');
    }

    // 2. Extract Firebase ID token
    final idToken = await firebaseUser.getIdToken();
    if (idToken == null) {
      throw const AuthException('Koodii ragaa (ID Token) argachuun hin danda\'amne.');
    }

    // 3. Exchange Firebase ID Token with Express Backend (/api/v1/auth/login)
    String? customBackendJwt;
    try {
      final endpoint = Uri.parse('$_backendBaseUrl/api/v1/auth/login');
      final response = await _secureHttpClient.post(
        uri: endpoint,
        body: {
          'idToken': idToken,
          'phoneNumber': firebaseUser.phoneNumber ?? '',
          'fullName': fullName,
          'schoolName': schoolName,
          'zoneName': zoneName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        customBackendJwt = responseData['token'] as String? ?? responseData['jwt'] as String?;
      } else {
        // Log backend rejection gracefully while preserving client usability
        customBackendJwt = null;
      }
    } on AuthNetworkException {
      // Fallback: If device is offline or backend unreachable, proceed with Firebase user session
      customBackendJwt = null;
    } on AuthTimeoutException {
      // Fallback: Timeout resilience
      customBackendJwt = null;
    } catch (_) {
      customBackendJwt = null;
    }

    return AuthUser(
      uid: firebaseUser.uid,
      phoneNumber: firebaseUser.phoneNumber ?? '',
      fullName: fullName,
      schoolName: schoolName,
      zoneName: zoneName,
      backendToken: customBackendJwt,
      isVerified: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final currentFirebaseUser = _firebaseAuth.currentUser;
    if (currentFirebaseUser == null) return null;

    final token = await currentFirebaseUser.getIdToken();
    return AuthUser(
      uid: currentFirebaseUser.uid,
      phoneNumber: currentFirebaseUser.phoneNumber ?? '',
      backendToken: token,
      isVerified: true,
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
