import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/student_track.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../widgets/track_selection_card.dart';

/// Screen 2: Profile & Track Selection (Filannoo Sagantaa)
/// Academic goal configuration with three large Material 3 selection cards.
class TrackSelectionScreen extends ConsumerStatefulWidget {
  const TrackSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TrackSelectionScreen> createState() => _TrackSelectionScreenState();
}

class _TrackSelectionScreenState extends ConsumerState<TrackSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  String _selectedZone = 'Shawaa Bahaa';
  StudentTrack _selectedTrack = StudentTrack.both; // Default to comprehensive preparation

  // All 21 official administrative zones of Oromia
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
  void initState() {
    super.initState();
    // Pre-fill existing user info if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(authNotifierProvider);
      if (state is OtpVerifiedState) {
        if (state.existingFullName != null && state.existingFullName!.isNotEmpty) {
          _nameController.text = state.existingFullName!;
        }
        if (state.existingSchool != null && state.existingSchool!.isNotEmpty) {
          _schoolController.text = state.existingSchool!;
        }
        if (state.existingZone != null && _oromiaZones.contains(state.existingZone)) {
          setState(() => _selectedZone = state.existingZone!);
        }
      } else if (state is AuthenticatedState) {
        if (state.user.fullName != null) {
          _nameController.text = state.user.fullName!;
        }
        if (state.user.schoolName != null) {
          _schoolController.text = state.user.schoolName!;
        }
        if (state.user.zoneName != null && _oromiaZones.contains(state.user.zoneName)) {
          setState(() => _selectedZone = state.user.zoneName!);
        }
        setState(() => _selectedTrack = state.track);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _handleComplete() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = _nameController.text.trim();
    final schoolName = _schoolController.text.trim().isNotEmpty
        ? _schoolController.text.trim()
        : 'Mana Barumsaa Sad. 1ffaa';

    await ref.read(authNotifierProvider.notifier).saveProfileAndTrack(
          fullName: fullName,
          schoolName: schoolName,
          zoneName: _selectedZone,
          track: _selectedTrack,
        );

    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          'Qophii Eenyummaa fi Sagantaa',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress & Academic Step Indicator
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Tarkaanfii 2 / 2',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Qophii 100%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1B6E32),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: const LinearProgressIndicator(
                                value: 1.0,
                                minHeight: 6,
                                backgroundColor: Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B6E32)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Odeeffannoo keessan galchaatii sagantaa qormaata ittiin qophaa\'uu barbaaddan filadhaa.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section 1: Academic Student Profile
                      const Text(
                        '1. Eenyummaa Barataa (Student Profile)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Full Name Input
                            const Text(
                              'Maqaa Guutuu',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'fkn: Tolasaa Baqqalaa',
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF0D47A1)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Maaloo maqaa guutuu galchaa';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Zone Selector
                            const Text(
                              'Godina / Bulchiinsa Magaalaa',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedZone,
                              isExpanded: true,
                              items: _oromiaZones.map((zone) {
                                return DropdownMenuItem(
                                  value: zone,
                                  child: Text(
                                    zone,
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedZone = val);
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF1B6E32)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // School Name
                            const Text(
                              'Mana Barumsaa (School)',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _schoolController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'fkn: Mana Barumsaa Sad. 1ffaa',
                                prefixIcon: const Icon(Icons.apartment_rounded, color: Color(0xFF64748B)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Section 2: Academic Track Selection
                      Row(
                        children: const [
                          Text(
                            '2. Filannoo Sagantaa Qormaataa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.stars_rounded, color: Color(0xFF0D47A1), size: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sagantaa qophii qormaataa armaan gadii keessaa isa si barbaachisu filadhu:',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),

                      // Option 1 Card: "Qormaata Ministeeraa Qofa"
                      TrackSelectionCard(
                        track: StudentTrack.ministryOnly,
                        isSelected: _selectedTrack == StudentTrack.ministryOnly,
                        onSelected: () => setState(() => _selectedTrack = StudentTrack.ministryOnly),
                      ),

                      // Option 2 Card: "Qormaata Ifa Boruu Qofa"
                      TrackSelectionCard(
                        track: StudentTrack.ifaBoruOnly,
                        isSelected: _selectedTrack == StudentTrack.ifaBoruOnly,
                        onSelected: () => setState(() => _selectedTrack = StudentTrack.ifaBoruOnly),
                      ),

                      // Option 3 Card: "Lachuu" (Prepare for both exams)
                      TrackSelectionCard(
                        track: StudentTrack.both,
                        isSelected: _selectedTrack == StudentTrack.both,
                        onSelected: () => setState(() => _selectedTrack = StudentTrack.both),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Sticky Action Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1), // Trustworthy Academic Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedCornerShape(14),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                      )
                    : Row(
                        mainAxisAlignment: MainContent.center,
                        children: const [
                          Text(
                            'Xumuri & Gara Fuulduraatti',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
