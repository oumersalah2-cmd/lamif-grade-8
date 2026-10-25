import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import 'otp_screen.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController(text: '9');
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  String _selectedZone = 'Shawaa Bahaa';

  final List<String> _oromiaZones = const [
    'Shawaa Bahaa',
    'Shawaa Dhihaa',
    'Shawaa Kaabaa',
    'Shawaa Kibba Lixaa',
    'Finfinnee Naannawaa',
    'Wallagga Bahaa',
    'Wallagga Dhihaa',
    'Qeellam Wallaggaa',
    'Horroo Guduruu Wallaggaa',
    'Jimma',
    'Iluu Abbaa Booraa',
    'Buno Baddallee',
    'Arsii',
    'Arsii Lixaa',
    'Baalee',
    'Baalee Bahaa',
    'Harargee Bahaa',
    'Harargee Dhihaa',
    'Gujii',
    'Gujii Lixaa',
    'Boorana',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _submitPhone() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lakkofsa bilbilaa sirrii galchaa (fkn: 911234567)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ref.read(authNotifierProvider.notifier).sendOtp(phone);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is OtpSentState) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              verificationId: next.verificationId,
              phoneNumber: next.phoneNumber,
              fullName: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : 'Barataa Kutaa 8ffaa',
              schoolName: _schoolController.text.trim(),
              zoneName: _selectedZone,
            ),
          ),
        );
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
        title: const Text(
          'Lamif Kutaa 8 - Seensa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1B6E32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B6E32), Color(0xFF155D27)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.school, size: 48, color: Color(0xFFFFD54F)),
                    SizedBox(height: 10),
                    Text(
                      'Baga Nagaan Dhuftan!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Qormaata Naannoo Oromiyaa Kutaa 8ffaatiif qophaa\'aa',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Lakkofsa Bilbilaa Galchaa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixText: '+251 ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  hintText: '9XXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF1B6E32)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Student Full Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Maqaa Guutuu (Full Name)',
                  hintText: 'Maqaa kee barreessi',
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF1B6E32)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Zone Dropdown
              DropdownButtonFormField<String>(
                value: _selectedZone,
                items: _oromiaZones.map((zone) {
                  return DropdownMenuItem(value: zone, child: Text(zone));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedZone = val);
                },
                decoration: InputDecoration(
                  labelText: 'Godina / Bulchiinsa Magaalaa',
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF1B6E32)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // School Name Field
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(
                  labelText: 'Mana Barumsaa (School)',
                  hintText: 'fkn: Mana Barumsaa Sad. 1ffaa',
                  prefixIcon: const Icon(Icons.apartment, color: Color(0xFF1B6E32)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _submitPhone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B6E32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedCornerShape(12),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Koodii OTP Ergi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 16),

              // Offline Guest Mode Button
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).continueAsGuest(
                        fullName: _nameController.text.trim().isNotEmpty
                            ? _nameController.text.trim()
                            : 'Barataa Kutaa 8ffaa (Offline)',
                        zoneName: _selectedZone,
                      );
                },
                icon: const Icon(Icons.offline_bolt, color: Color(0xFFD97706)),
                label: const Text(
                  'Intarneetii Malee Itti Fufi (Offline Mode)',
                  style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                  shape: RoundedCornerShape(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
