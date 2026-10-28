import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/student_track.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import 'admin_pin_reset_dialog.dart';

/// Screen: Initial Account Creation & Online Device Login
/// Internet required once at signup; afterwards student uses 100% offline PIN.
class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Signup Controllers
  final _signupFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _schoolController = TextEditingController();
  final _signupPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String _selectedZone = 'Shawaa Bahaa';
  StudentTrack _selectedTrack = StudentTrack.both;

  // Login Controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginPhoneController = TextEditingController();
  final _loginPinController = TextEditingController();
  bool _obscurePin = true;

  final List<String> _oromiaZones = [
    'Shawaa Bahaa',
    'Shawaa Dhihaa',
    'Shawaa Kaabaa',
    'Addis Ababa / Finfinnee',
    'Arsii',
    'Arsii Lixaa',
    'Baale',
    'Baale Bahaa',
    'Boorana',
    'Gujii',
    'Gujii Lixaa',
    'Harargee Bahaa',
    'Harargee Lixaa',
    'Iluu Abbaa Booraa',
    'Jimmaa',
    'Bunnoo Baddallee',
    'Qellem Wallaggaa',
    'Wallagga Bahaa',
    'Wallagga Lixaa',
    'Horo Guduruu Wallaggaa',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _signupPhoneController.dispose();
    _schoolController.dispose();
    _signupPinController.dispose();
    _confirmPinController.dispose();
    _loginPhoneController.dispose();
    _loginPinController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    FocusScope.of(context).unfocus();
    if (!_signupFormKey.currentState!.validate()) return;

    final pin = _signupPinController.text.trim();
    final confirm = _confirmPinController.text.trim();

    if (pin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PIN lachuu wal hin simne (PINs do not match).'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(authNotifierProvider.notifier).signupWithPin(
          name: _nameController.text.trim(),
          phone: _signupPhoneController.text.trim(),
          schoolZone: _selectedZone,
          schoolName: _schoolController.text.trim().isEmpty ? null : _schoolController.text.trim(),
          track: _selectedTrack,
          pin: pin,
        );
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    if (!_loginFormKey.currentState!.validate()) return;

    ref.read(authNotifierProvider.notifier).loginOnline(
          phone: _loginPhoneController.text.trim(),
          pin: _loginPinController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    // React to auth state transitions
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthenticatedState) {
        context.go('/dashboard');
      } else if (next is AuthPinRequiredState) {
        context.go('/pin-login');
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lamif Kutaa 8 Prep',
          style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF15803D),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF15803D),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Galmaa'i (Sign Up)"),
            Tab(text: "Seeni (Online Login)"),
          ],
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF15803D)),
                    const SizedBox(height: 16),
                    Text(
                      (authState as AuthLoading).message ?? 'Eegaa...',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildSignupTab(),
                  _buildLoginTab(),
                ],
              ),
      ),
    );
  }

  // ==========================================================================
  // SIGNUP TAB (Requires internet once)
  // ==========================================================================

  Widget _buildSignupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informational badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.wifi_rounded, color: Color(0xFF15803D), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Intarneetiin kan barbaachisu yeroo galmee qofa. Sana booda offline guutummaatti ni hojjeta.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Student Full Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Maqaa Guutuu (Full Name)',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Maqaan barbaachisaadha' : null,
            ),

            const SizedBox(height: 14),

            // Phone Number
            TextFormField(
              controller: _signupPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Lakkoofsa Bilbilaa (Phone)',
                hintText: '0911000000',
                prefixIcon: Icon(Icons.phone_android_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().length < 9 ? 'Bilbilli sirrii miti' : null,
            ),

            const SizedBox(height: 14),

            // Oromia Administrative Zone
            DropdownButtonFormField<String>(
              value: _selectedZone,
              decoration: const InputDecoration(
                labelText: 'Godina (School Zone)',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              items: _oromiaZones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedZone = val);
              },
            ),

            const SizedBox(height: 14),

            // School Name (Optional)
            TextFormField(
              controller: _schoolController,
              decoration: const InputDecoration(
                labelText: 'Mana Barumsaa (School Name - Filannoo)',
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 14),

            // Track Selection
            const Text(
              'Sagantaa Qophii (Preparation Track):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: StudentTrack.values.map((track) {
                final isSelected = _selectedTrack == track;
                return ChoiceChip(
                  label: Text('${track.titleOm} (${track.priceEtb} ETB)'),
                  selected: isSelected,
                  selectedColor: const Color(0xFFDCFCE7),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTrack = track);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 6-digit PIN input
            TextFormField(
              controller: _signupPinController,
              keyboardType: TextInputType.number,
              obscureText: _obscurePin,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'PIN Dijiitii 6 Filadhaa (Create 6-Digit PIN)',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ),
              validator: (v) => v == null || v.trim().length != 6 ? 'PIN dijiitii 6 ta\'uu qaba' : null,
            ),

            const SizedBox(height: 14),

            // Confirm PIN input
            TextFormField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: _obscurePin,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'PIN Irra Deebi\'aa (Confirm 6-Digit PIN)',
                prefixIcon: Icon(Icons.check_circle_outline),
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: (v) => v == null || v.trim().length != 6 ? 'PIN mirkaneessaa' : null,
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _handleSignup,
                child: const Text('Galmaa\'i (Create Account)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 16),

            // Guest Mode exploration
            OutlinedButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).continueAsGuest(),
              child: const Text('Sarara-Malee Qofa Ilaali (Guest Mode)'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ONLINE LOGIN TAB (New phone / reinstall)
  // ==========================================================================

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bilbila Haaraa Irraa Seenuuf',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your registered phone and PIN to sync account',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _loginPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Lakkoofsa Bilbilaa (Phone)',
                hintText: '0911000000',
                prefixIcon: Icon(Icons.phone_android_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().length < 9 ? 'Bilbila galchaa' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _loginPinController,
              keyboardType: TextInputType.number,
              obscureText: _obscurePin,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'PIN Dijiitii 6 (PIN)',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ),
              validator: (v) => v == null || v.trim().length != 6 ? 'PIN dijiitii 6 galchaa' : null,
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => AdminPinResetDialog.show(context),
                child: const Text('PIN Dhabde? (Forgot PIN)'),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _handleLogin,
                child: const Text('Seeni (Log In)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).continueAsGuest(),
              child: const Text('Sarara-Malee Qofa Ilaali (Guest Mode)'),
            ),
          ],
        ),
      ),
    );
  }
}
