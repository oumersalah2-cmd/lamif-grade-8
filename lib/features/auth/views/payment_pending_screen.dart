import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/payment_status.dart';
import '../models/student_track.dart';
import '../providers/auth_notifier.dart';
import '../services/payment_service.dart';

/// Screen displayed when user has submitted payment receipt and is awaiting admin verification.
/// Locks user out of main exam and study content until backend returns VERIFIED.
class PaymentPendingScreen extends ConsumerStatefulWidget {
  const PaymentPendingScreen({super.key});

  @override
  ConsumerState<PaymentPendingScreen> createState() => _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends ConsumerState<PaymentPendingScreen>
    with SingleTickerProviderStateMixin {
  final PaymentService _paymentService = PaymentService();
  bool _isChecking = false;
  String? _statusMessage;
  Timer? _pollingTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initial check and auto-poll every 25 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus(showFeedback: false);
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (mounted) {
        _checkStatus(showFeedback: false);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus({bool showFeedback = true}) async {
    final user = ref.read(currentUserProvider);
    final phone = user?.phoneNumber;
    if (phone == null || phone.isEmpty) return;

    if (showFeedback) {
      setState(() {
        _isChecking = true;
        _statusMessage = null;
      });
    }

    try {
      final status = await _paymentService.checkPaymentStatus(phone);

      if (!mounted) return;

      if (status == PaymentStatus.verified) {
        // Unlock access!
        await ref.read(authNotifierProvider.notifier).updatePaymentStatus(PaymentStatus.verified);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Baga gammaddan! Kaffaltiin keessan mirkanaa\'eera.'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          context.go('/dashboard');
        }
      } else if (status == PaymentStatus.rejected) {
        await ref.read(authNotifierProvider.notifier).updatePaymentStatus(PaymentStatus.rejected);
        if (mounted && showFeedback) {
          setState(() {
            _statusMessage = 'Nagaheen kaffaltii hin mirkanoofne. Maaloo irra deebi\'aa nagahee qulqulluu fe\'aa.';
          });
        }
      } else {
        if (mounted && showFeedback) {
          setState(() {
            _statusMessage = 'Nagaheen keessan ammas qoratamaa jira. Maaloo daaqiiqaa muraasa booda irra deebi\'aa ilaalaa.';
          });
        }
      }
    } catch (e) {
      if (mounted && showFeedback) {
        setState(() {
          _statusMessage = 'Qunnamtiin serverii hin milkoofne: $e';
        });
      }
    } finally {
      if (mounted && showFeedback) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final track = ref.watch(studentTrackProvider);
    final paymentStatus = user?.paymentStatus ?? PaymentStatus.pending;
    final isRejected = paymentStatus == PaymentStatus.rejected;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Haala Kaffaltii (Verification)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Ba\'i (Sign Out)',
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Animated Pulsing Status Icon
              ScaleTransition(
                scale: isRejected ? const AlwaysStoppedAnimation(1.0) : _pulseAnimation,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: paymentStatus.backgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: paymentStatus.color.withOpacity(0.2),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    paymentStatus.icon,
                    size: 46,
                    color: paymentStatus.color,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Status Title
              Text(
                isRejected
                    ? 'Kaffaltiin Hin Mirkannoofne'
                    : 'Nagaheen Kaffaltii Qoratamaa Jira',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 8),

              // Afaan Oromoo Subtitle
              Text(
                isRejected
                    ? 'Nagaheen kaffaltii keessanii hin mirkanoofne. Maaloo nagahee sirrii ta\'e irra deebi\'aa fe\'aa.'
                    : 'Nagaheen kaffaltii keessanii dhiyaateera. Qorannoon Telebirr fi Baankii daaqiiqaa 15-30 keessatti xumuramee qormaanni guutuu isiniif banama.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 24),

              // Summary Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      label: 'Barataa (Student)',
                      value: user?.fullName ?? 'Barataa Kutaa 8ffaa',
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildDetailRow(
                      label: 'Lakkoofsa Bilbilaa',
                      value: user?.phoneNumber ?? '-',
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildDetailRow(
                      label: 'Godina (School Zone)',
                      value: user?.zoneName ?? 'Oromiyaa',
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildDetailRow(
                      label: 'Sagantaa Filatame',
                      value: track.titleOm,
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildDetailRow(
                      label: 'Gatii Kaffalame',
                      value: track.priceDisplay,
                      valueColor: const Color(0xFF0F3D3E),
                      isBold: true,
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildDetailRow(
                      label: 'Haala Kaffaltii',
                      valueWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: paymentStatus.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          paymentStatus.titleOm,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: paymentStatus.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: const TextStyle(color: Color(0xFF92400E), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Action Buttons
              if (isRejected) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        '/payment-verification',
                        extra: {
                          'track': track,
                          'name': user?.fullName ?? '',
                          'phone': user?.phoneNumber ?? '',
                          'zone': user?.zoneName ?? '',
                          'school': user?.schoolName ?? '',
                        },
                      );
                    },
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Nagahee Haaraa Fe\'i (Re-upload)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : () => _checkStatus(showFeedback: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3D3E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Haala Kaffaltii Mirkaneessi',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Support contact help box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.support_agent_rounded, size: 18, color: Color(0xFF475569)),
                    SizedBox(width: 8),
                    Text(
                      'Gargaarsaaf: +251 911 223 344 (Telegram)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    String? value,
    Widget? valueWidget,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        if (valueWidget != null)
          valueWidget
        else
          Text(
            value ?? '-',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
      ],
    );
  }
}
