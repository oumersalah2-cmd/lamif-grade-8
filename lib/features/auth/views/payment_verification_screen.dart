import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../models/payment_status.dart';
import '../models/student_track.dart';
import '../providers/auth_notifier.dart';
import '../services/payment_service.dart';

/// Screen for displaying Telebirr / Bank payment details and uploading screenshot receipt
class PaymentVerificationScreen extends ConsumerStatefulWidget {
  final StudentTrack track;
  final String studentName;
  final String phoneNumber;
  final String schoolZone;
  final String? schoolName;

  const PaymentVerificationScreen({
    super.key,
    required this.track,
    required this.studentName,
    required this.phoneNumber,
    required this.schoolZone,
    this.schoolName,
  });

  @override
  ConsumerState<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends ConsumerState<PaymentVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  final PaymentService _paymentService = PaymentService();
  XFile? _selectedReceiptImage;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Ethiopian Bank and Telebirr Payment Details
  final String _telebirrNumber = '0911223344';
  final String _telebirrAccountName = 'Lamif Academy / Oumer S.';
  final String _cbeAccountNumber = '1000123456789';
  final String _cbeAccountName = 'Lamif Kutaa 8 Prep';
  final String _awashAccountNumber = '01320876543210';
  final String _awashAccountName = 'Lamif Academy';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedReceiptImage = picked;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Suuraa filachuun hin danda\'amne: $e';
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('$label ($text) waraabbameera! (Copied)')),
          ],
        ),
        backgroundColor: const Color(0xFF0F3D3E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedReceiptImage == null) {
      setState(() {
        _errorMessage = 'Maaloo dura nagahee kafaltii (screenshot) fe\'aa!';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final result = await _paymentService.registerPayment(
        name: widget.studentName,
        phone: widget.phoneNumber,
        schoolZone: widget.schoolZone,
        schoolName: widget.schoolName,
        track: widget.track,
        receiptImage: _selectedReceiptImage!,
      );

      if (!mounted) return;

      if (result.success) {
        // Update local auth state with PENDING status
        await ref.read(authNotifierProvider.notifier).recordPaymentSubmitted(
              track: widget.track,
              fullName: widget.studentName,
              schoolName: widget.schoolName ?? '',
              zoneName: widget.schoolZone,
              receiptUrl: result.receiptUrl,
              amountPaid: widget.track.priceEtb.toDouble(),
            );

        if (mounted) {
          context.go('/payment-pending');
        }
      } else {
        setState(() {
          _errorMessage = result.message;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Dogoggorri erguu uumameera: $e';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.track.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Kaffaltii fi Mirkaneessa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Track & Amount Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Sagantaa Filatame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          widget.track.priceDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.track.titleOm,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Barataa: ${widget.studentName} (${widget.phoneNumber})',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Instructions Header
              const Text(
                'Tarkaanfilee Kaffaltii (Payment Steps)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Kaffaltii karaa Telebirr ykn Baankii dhiyeessuun nagahee (screenshot) asitti ol-fe\'aa.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 16),

              // Telebirr Payment Card
              _buildPaymentMethodCard(
                icon: Icons.phone_android_rounded,
                iconColor: const Color(0xFF0284C7),
                title: 'Telebirr',
                accountNumber: _telebirrNumber,
                accountName: _telebirrAccountName,
                tagText: 'Filatamaa & Saffisaa',
                onCopy: () => _copyToClipboard(_telebirrNumber, 'Telebirr'),
              ),

              const SizedBox(height: 12),

              // CBE Payment Card
              _buildPaymentMethodCard(
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Baankii Daldala Itoophiyaa (CBE)',
                accountNumber: _cbeAccountNumber,
                accountName: _cbeAccountName,
                onCopy: () => _copyToClipboard(_cbeAccountNumber, 'CBE'),
              ),

              const SizedBox(height: 12),

              // Awash Bank Payment Card
              _buildPaymentMethodCard(
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFF0D9488),
                title: 'Baankii Hawaash (Awash Bank)',
                accountNumber: _awashAccountNumber,
                accountName: _awashAccountName,
                onCopy: () => _copyToClipboard(_awashAccountNumber, 'Awash Bank'),
              ),

              const SizedBox(height: 24),

              // Receipt Upload Section Header
              const Text(
                'Nagahee Kaffaltii Ol-fe\'aa (Upload Screenshot)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Erga kaffaltanii booda nagahee bilbila keessaniin qabattanii filadhaa.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 14),

              // Image Picker Area
              if (_selectedReceiptImage == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          size: 30,
                          color: Color(0xFF0F3D3E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Suuraa nagahee asitti filadhaa',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'JPG, PNG, ykn WebP (hanga 10MB)',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_rounded, size: 18),
                            label: const Text('Gaalerii'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F3D3E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded, size: 18),
                            label: const Text('Kaameraa'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F3D3E),
                              side: const BorderSide(color: Color(0xFF0F3D3E), width: 1.2),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Selected Image Preview Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedReceiptImage!.name.isNotEmpty
                                  ? _selectedReceiptImage!.name
                                  : 'Nagahee filatame',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                            tooltip: 'Haqi (Remove)',
                            onPressed: () {
                              setState(() {
                                _selectedReceiptImage = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Image Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: kIsWeb
                              ? Image.network(
                                  _selectedReceiptImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedReceiptImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Suuraa Jijjiiri (Change)'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0F3D3E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Error display
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF87171)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () async {
                          await ref.read(authNotifierProvider.notifier).recordPaymentSubmitted(
                                track: widget.track,
                                fullName: widget.studentName,
                                schoolName: widget.schoolName ?? '',
                                zoneName: widget.schoolZone,
                                receiptUrl: _selectedReceiptImage?.path,
                                amountPaid: widget.track.priceEtb.toDouble(),
                              );
                          if (context.mounted) {
                            context.go('/payment-pending');
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF991B1B)),
                        label: const Text(
                          'Sarara-malee itti fufi (Save Offline & Proceed to Pending)',
                          style: TextStyle(
                            color: Color(0xFF991B1B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3D3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Nagahee Ergi & Galmee Xumuri',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Dev / Quick Preview Bypass for Instant Testing
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).saveProfileAndTrack(
                          fullName: widget.studentName,
                          schoolName: widget.schoolName ?? 'Mana Barumsaa',
                          zoneName: widget.schoolZone,
                          track: widget.track,
                        );
                    await ref.read(authNotifierProvider.notifier).updatePaymentStatus(PaymentStatus.verified);
                    if (context.mounted) {
                      context.go('/dashboard');
                    }
                  },
                  icon: const Icon(Icons.bolt_rounded, size: 18, color: Color(0xFF16A34A)),
                  label: const Text(
                    'Fuula Duraa Yaali (Dev Quick Preview)',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String accountNumber,
    required String accountName,
    String? tagText,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      accountName,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (tagText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tagText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  accountNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Color(0xFF0F172A),
                  ),
                ),
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: const [
                        Icon(Icons.copy_rounded, size: 16, color: Color(0xFF0F3D3E)),
                        SizedBox(width: 4),
                        Text(
                          'Waraabi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F3D3E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
