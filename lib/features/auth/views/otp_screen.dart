import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String? fullName;
  final String? schoolName;
  final String? zoneName;

  const OtpScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    this.fullName,
    this.schoolName,
    this.zoneName,
  }) : super(key: key);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _verifyOtp() {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koodii dijiitii 6 galchaa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(authNotifierProvider.notifier).verifyOtp(
          smsCode: code,
          fullName: widget.fullName,
          schoolName: widget.schoolName,
          zoneName: widget.zoneName,
        );
  }

  void _resendOtp() {
    if (_secondsRemaining == 0) {
      ref.read(authNotifierProvider.notifier).sendOtp(widget.phoneNumber);
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthenticatedState) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (next is AuthErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessageOm),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Mirkaneessa Koodii OTP'),
        backgroundColor: const Color(0xFF1B6E32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: Color(0xFF1B6E32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Koodiin Mirkaneessaa Ergameera',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Koodii lakkoofsa 6 gara bilbila ${widget.phoneNumber} irratti ergame galchaa.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // OTP Input
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '------',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Verify Button
              ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B6E32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Koodii Mirkaneessi (Verify)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 20),

              // Resend countdown
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Koodii deebisanii erguuf: $_secondsRemaining sekondii',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        child: const Text(
                          'Koodii Deebisii Ergi (Resend OTP)',
                          style: TextStyle(
                            color: Color(0xFF1B6E32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
