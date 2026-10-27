import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

/// Screen 1: Phone Auth Login (Seensa)
/// Clean, minimalist, and academic design inspired by EthioMatric.
class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _handleSendOtp() {
    FocusScope.of(context).unfocus();
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty || rawPhone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maaloo lakkoofsa bilbilaa sirrii galchaa (fkn: 911234567)'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(authNotifierProvider.notifier).sendOtp(rawPhone);
  }

  void _handleVerifyOtp() {
    FocusScope.of(context).unfocus();
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maaloo koodii OTP dijiitii 6 galchaa.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(authNotifierProvider.notifier).verifyOtp(smsCode: otp);
  }

  void _handleResendOtp(String phoneNumber) {
    if (_resendCountdown == 0) {
      ref.read(authNotifierProvider.notifier).sendOtp(phoneNumber);
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    // Listen for authentication transitions to navigate via GoRouter
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is OtpSentState) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Koodiin OTP gara ${next.phoneNumber} ergameera.'),
            backgroundColor: const Color(0xFF1B6E32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next is OtpVerifiedState) {
        // Phone verified! Route directly to Track & Profile Selection
        context.go('/onboarding/track-selection');
      } else if (next is AuthenticatedState) {
        if (next.isOnboarded) {
          context.go('/dashboard');
        } else {
          context.go('/onboarding/track-selection');
        }
      } else if (next is AuthErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessageOm),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () => ref.read(authNotifierProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });

    final isOtpStep = authState is OtpSentState;
    final sentPhone = isOtpStep ? (authState as OtpSentState).phoneNumber : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // EthioMatric Inspired Academic Brand Header
              Center(
                child: Column(
                  children: [
                    // Academic Shield / Lamp Emblem
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1B6E32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0D47A1).withOpacity(0.22),
                            offset: const Offset(0, 8),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App Title
                    const Text(
                      'Lamif Kutaa 8 Prep',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle in Afaan Oromoo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Sirna Qophii Qormaata Oromiyaa',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Title Section: Seensa / Galmee
              Text(
                isOtpStep ? 'Koodii Mirkaneessi' : 'Seensa (Login)',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isOtpStep
                    ? 'Koodii dijiitii 6 bilbila $sentPhone irratti ergame galchaa.'
                    : 'Qormaataaf qophaa\'uuf lakkoofsa bilbilaa keessan galchaa.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Step 1: Phone Input Form
              if (!isOtpStep) ...[
                const Text(
                  'Lakkoofsa Bilbilaa Galchi',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),

                // Phone Input Field with +251 Prefix
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      // Prefix badge (+251)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.flag_circle_rounded, size: 20, color: Color(0xFF1B6E32)),
                            SizedBox(width: 6),
                            Text(
                              '+251',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Number text field
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Color(0xFF0F172A),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                            hintText: '9XXXXXXXX',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onFieldSubmitted: (_) => _handleSendOtp(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // "Koodii Ergi" (Send Code) Button
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1), // Trustworthy Deep Blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Koodii Ergi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ],

              // Step 2: OTP Entry Field
              if (isOtpStep) ...[
                const Text(
                  'Koodii Dijiitii 6 (OTP)',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),

                // Clean Elevated OTP Box
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 12,
                    color: Color(0xFF0D47A1),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    hintStyle: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      letterSpacing: 10,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onFieldSubmitted: (_) => _handleVerifyOtp(),
                ),

                const SizedBox(height: 20),

                // "Mirkaneessi" (Verify) Button
                ElevatedButton(
                  onPressed: isLoading ? null : _handleVerifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6E32), // Deep Growth Green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Text(
                          'Mirkaneessi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),

                const SizedBox(height: 18),

                // Resend OTP / Change Phone row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).resetToPhoneInput();
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text(
                        'Bilbila Jijjiiri',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    _resendCountdown > 0
                        ? Text(
                            'Koodii erguuf: ${_resendCountdown}s',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : TextButton(
                            onPressed: () => _handleResendOtp(sentPhone),
                            child: const Text(
                              'Deebisii Ergi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ),
                  ],
                ),
              ],

              const SizedBox(height: 36),

              // Clean Divider
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Yookiin',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                ],
              ),

              const SizedBox(height: 24),

              // Offline Guest Mode Button
              OutlinedButton.icon(
                onPressed: () {
                  // Instant offline access to proceed without SIM
                  ref.read(authNotifierProvider.notifier).continueAsGuest();
                  context.go('/onboarding/track-selection');
                },
                icon: const Icon(Icons.offline_bolt_rounded, color: Color(0xFFD97706), size: 20),
                label: const Text(
                  'Intarneetii Malee Itti Fufi (Offline Mode)',
                  style: TextStyle(
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFFBBF24), width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: const Color(0xFFFFFBEB),
                ),
              ),

              const SizedBox(height: 32),

              // Academic Trust Footer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text(
                      'Biiroo Barnoota Oromiyaa • Qormaata Kutaa 8ffaa',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
