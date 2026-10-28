import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';

/// Modal dialog for student to enter 15-minute one-time recovery code from school admin/teacher
class AdminPinResetDialog extends ConsumerStatefulWidget {
  const AdminPinResetDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const AdminPinResetDialog(),
    );
  }

  @override
  ConsumerState<AdminPinResetDialog> createState() => _AdminPinResetDialogState();
}

class _AdminPinResetDialogState extends ConsumerState<AdminPinResetDialog> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final pin = _pinController.text.trim();
    final confirm = _confirmPinController.text.trim();

    if (pin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN lachuu wal hin simne (PINs do not match).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref.read(authNotifierProvider.notifier).resetPinWithCode(
          phone: phone,
          resetCode: code,
          newPin: pin,
        );
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN haaraan milkaa\'inaan jijjiirameera. Amma ittiin seenaa.'),
          backgroundColor: Color(0xFF15803D),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.lock_reset_rounded, color: Color(0xFF15803D)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'PIN Deebisi (Admin PIN Reset)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Koodii yeroo tokkoo barsiisaa ykn admin keessan irraa fudhattan asitti galchaa (Enter one-time code from teacher/admin):',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Lakkoofsa Bilbilaa (Phone)',
                  hintText: '0911000000',
                  prefixIcon: Icon(Icons.phone_android_rounded),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) => val == null || val.length < 9 ? 'Bilbila sirrii galchaa' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Koodii Deebisaa Dijiitii 6 (Reset Code)',
                  hintText: '123456',
                  prefixIcon: Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) => val == null || val.length != 6 ? 'Koodii dijiitii 6 galchaa' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'PIN Haaraa Dijiitii 6 (New PIN)',
                  prefixIcon: Icon(Icons.password_rounded),
                  border: OutlineInputBorder(),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) => val == null || val.length != 6 ? 'PIN dijiitii 6 filadhaa' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'PIN Haaraa Irra Deebi\'i (Confirm PIN)',
                  prefixIcon: Icon(Icons.check_circle_outline_rounded),
                  border: OutlineInputBorder(),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) => val == null || val.length != 6 ? 'PIN irra deebisaa' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dhiisi (Cancel)'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF15803D),
            foregroundColor: Colors.white,
          ),
          onPressed: _isLoading ? null : _handleReset,
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('PIN Jijjiiri (Reset PIN)'),
        ),
      ],
    );
  }
}
