import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import 'admin_pin_reset_dialog.dart';

/// Screen: Daily Offline PIN Login (Seensa PIN Guyyaa)
/// Works 100% offline with locally stored PBKDF2 salted hash.
/// Features large touch targets (68x68dp), high-contrast accessibility,
/// real-time lockout timer, and account switching.
class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _enteredPin = '';
  bool _isPinVisible = false;
  Timer? _lockoutTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _syncLockoutState();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _syncLockoutState() {
    final state = ref.read(authNotifierProvider);
    if (state is AuthPinRequiredState && state.isLocked) {
      _startCountdown(state.remainingLockoutSeconds);
    }
  }

  void _startCountdown(int seconds) {
    _lockoutTimer?.cancel();
    setState(() => _secondsRemaining = seconds);

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        ref.read(authNotifierProvider.notifier).checkInitialSession();
      }
    });
  }

  void _onKeyPress(String digit) {
    if (_secondsRemaining > 0) {
      HapticFeedback.vibrate();
      return;
    }
    if (_enteredPin.length < 6) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin += digit;
      });

      if (_enteredPin.length == 6) {
        _submitPin();
      }
    }
  }

  void _onDeletePress() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _onClearPress() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _enteredPin = '';
      });
    }
  }

  Future<void> _submitPin() async {
    final pin = _enteredPin;
    final success = await ref.read(authNotifierProvider.notifier).verifyOfflinePin(pin);

    if (!success) {
      HapticFeedback.heavyImpact();
      setState(() => _enteredPin = '');

      final state = ref.read(authNotifierProvider);
      if (state is AuthPinRequiredState) {
        if (state.requiresOnlineRecovery) {
          _showRecoveryRequiredDialog();
        } else if (state.isLocked) {
          _startCountdown(state.remainingLockoutSeconds);
        } else {
          final attemptsLeft = 5 - state.failedAttempts;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'PIN sirrii miti. Yaalii ${state.failedAttempts}/5 (Attempts remaining: $attemptsLeft).',
              ),
              backgroundColor: Colors.red.shade800,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showRecoveryRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Cufama Cimaa (Lockout Alert)'),
        content: const Text(
          'Yeroo 10 oliif PIN dogoggoraa galchitan. Appilikeeshinii deebisanii banuuf sarara intarneetii qabaachuu fi koodii deebisaa barsiisaa/admin irraa fudhachuun barbaachisaadha.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AdminPinResetDialog.show(context);
            },
            child: const Text('Koodii Deebisaa Galchi (Enter Reset Code)'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).switchAccount();
              context.go('/login');
            },
            child: const Text('Herrega Jijjiiri'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final pinState = authState is AuthPinRequiredState ? authState : null;
    final studentName = pinState?.studentName ?? 'Barataa Kutaa 8ffaa';
    final isLocked = _secondsRemaining > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Seensa PIN (Offline PIN Login)',
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).switchAccount();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: Color(0xFF15803D)),
            label: const Text(
              'Jijjiiri',
              style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Profile Avatar & Welcome Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Icons.person, color: Color(0xFF15803D), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'PIN Dijiitii 6 Galchaa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your 6-digit PIN to study offline',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 20),

            // Lockout Banner or PIN Indicator Dots
            if (isLocked) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_clock_rounded, color: Color(0xFFDC2626), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Cufameera: ${_formatCountdown(_secondsRemaining)} eegaa',
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildPinDotsRow(),
            ],

            const Spacer(),

            // Large Touch Target Numeric Keypad (Minimum 48x48dp, rendered at 68x68dp)
            _buildKeypad(),

            const SizedBox(height: 12),

            // Forgot PIN & Switch Account Action Links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => AdminPinResetDialog.show(context),
                  child: const Text(
                    'PIN Dhabde? (Forgot PIN)',
                    style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isPinVisible = !_isPinVisible),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPinVisible ? Icons.visibility_off : Icons.visibility,
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isPinVisible ? 'Dhoksaa' : 'Agarsiisi',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDotsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < _enteredPin.length;
        final char = isFilled && _isPinVisible ? _enteredPin[index] : null;

        return Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? const Color(0xFF15803D) : Colors.transparent,
            border: Border.all(
              color: isFilled ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
              width: 2,
            ),
          ),
          child: char != null
              ? Text(
                  char,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                )
              : null,
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '⌫'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == 'C') {
                  return _buildKeyButton(
                    label: 'C',
                    semanticLabel: 'Qulqulleessi (Clear)',
                    onTap: _onClearPress,
                    isSpecial: true,
                  );
                } else if (key == '⌫') {
                  return _buildKeyButton(
                    label: '⌫',
                    semanticLabel: 'Haqi (Backspace)',
                    onTap: _onDeletePress,
                    isSpecial: true,
                  );
                } else {
                  return _buildKeyButton(
                    label: key,
                    semanticLabel: 'Lakkoofsa $key',
                    onTap: () => _onKeyPress(key),
                  );
                }
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyButton({
    required String label,
    required String semanticLabel,
    required VoidCallback onTap,
    bool isSpecial = false,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: isSpecial ? const Color(0xFFF1F5F9) : Colors.white,
        shape: const CircleBorder(),
        elevation: isSpecial ? 0 : 1,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSpecial ? 18 : 24,
                fontWeight: FontWeight.bold,
                color: isSpecial ? const Color(0xFF475569) : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCountdown(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
