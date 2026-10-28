import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/analytics/analytics_service.dart';
import '../auth/providers/auth_notifier.dart';

/// Bilingual Privacy & Telemetry Settings Dialog
/// Complies with Google Play Data Safety and User Consent requirements.
class PrivacySettingsDialog extends ConsumerStatefulWidget {
  const PrivacySettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const PrivacySettingsDialog(),
    );
  }

  @override
  ConsumerState<PrivacySettingsDialog> createState() => _PrivacySettingsDialogState();
}

class _PrivacySettingsDialogState extends ConsumerState<PrivacySettingsDialog> {
  late bool _analyticsConsent;

  @override
  void initState() {
    super.initState();
    _analyticsConsent = ref.read(analyticsServiceProvider).hasConsent;
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.read(analyticsServiceProvider);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.security_rounded, color: Color(0xFF15803D)),
          SizedBox(width: 10),
          Text(
            'Qindaa\'ina Dhuunfaa (Privacy)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Odeeffannoo Tajaajilaa (Data & Crash Logging)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Appilikeeshiniin kun dogoggora sirreessuuf ragaalee teeknikaa (crash logs) qofa funaana. Maqaa, bilbila, suuraa nagahee ykn deebii qormaataa hin ergu.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
            ),
            const SizedBox(height: 2),
            const Text(
              'This app only logs anonymized crash & diagnostic events to improve reliability. No names, phone numbers, receipts, or answers are ever tracked.',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),

            // Consent Switch Tile
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF15803D),
              title: const Text(
                'Gabaasa Dogoggoraa Eyyami',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Allow Crashlytics & Analytics collection',
                style: TextStyle(fontSize: 11.5, color: Colors.grey),
              ),
              value: _analyticsConsent,
              onChanged: (val) async {
                setState(() => _analyticsConsent = val);
                await analytics.setConsent(val);
              },
            ),

            const Divider(height: 24),

            // In-app Account Deletion Option (Mandatory Play Store policy)
            const Text(
              'Herrega Haquu (Delete Account & Data)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ragaa kee hunda (maqaa, bilbila, qabxii qormaataa fi nagahee) guutummaatti haquuf:',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _confirmAccountDeletion(context),
                icon: const Icon(Icons.delete_forever, size: 18),
                label: const Text('Herrega Koo Haqi (Delete Account)', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cufi (Close)'),
        ),
      ],
    );
  }

  void _confirmAccountDeletion(BuildContext context) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mirkaneessa Haqiisaa (Confirm Deletion)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Akeekkachiisa Cimaa: Herrega kee yoo haqxe, qabxiin qormaataa, sochii qayyabannoo fi nagaheen kaffaltii kee serverii irraa guutummaatti ni bada. Deebi\'ee hin argamu.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFFDC2626), height: 1.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mirkaneessuuf PIN kee dijiitii 6 galchaa (Enter 6-digit PIN to verify):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: '••••••',
                border: OutlineInputBorder(),
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dhiisi (Cancel)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () async {
              final pin = pinController.text.trim();
              if (pin.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN dijiitii 6 galchaa.')),
                );
                return;
              }

              Navigator.pop(ctx);
              Navigator.pop(context); // Close settings dialog

              final success = await ref.read(authNotifierProvider.notifier).deleteAccount(pin: pin);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Herregni fi ragaan kee guutummaatti haqameera (Account deleted).'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
              }
            },
            child: const Text('Eeyyee, Dhaabbataan Haqi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
