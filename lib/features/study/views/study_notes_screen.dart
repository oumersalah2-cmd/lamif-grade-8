import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_material_model.dart';
import '../models/subject_model.dart';
import '../repositories/study_material_repository.dart';

/// Screen displaying Grade 8 study notes, summary topics, formulas, and Ministry Exam tips.
/// Fully offline-capable and natively localized in Afaan Oromoo.
class StudyNotesScreen extends ConsumerStatefulWidget {
  const StudyNotesScreen({super.key});

  @override
  ConsumerState<StudyNotesScreen> createState() => _StudyNotesScreenState();
}

class _StudyNotesScreenState extends ConsumerState<StudyNotesScreen> {
  String? _selectedSubjectId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Qayyabannoo & Yaadannoo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Mata-dureewwan ykn seera barbaadi...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: subjectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('Dogoggora: $err', style: const TextStyle(color: Colors.red)),
          ),
          data: (subjects) {
            if (subjects.isEmpty) {
              return const Center(child: Text('Gosti barnootaa hin argamne.'));
            }

            // Default to first subject if none selected
            final currentSubjectId = _selectedSubjectId ?? subjects.first.id;

            return Column(
              children: [
                // 1. Subject Chips Filter
                _buildSubjectFilter(subjects, currentSubjectId),

                // 2. Offline Ready Banner
                _buildOfflineBanner(context),

                // 3. Material List for Selected Subject
                Expanded(
                  child: _buildMaterialsList(currentSubjectId, theme),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubjectFilter(List<SubjectModel> subjects, String currentSubjectId) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subj = subjects[index];
          final isSelected = subj.id == currentSubjectId;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(subj.nameOm),
              selected: isSelected,
              selectedColor: const Color(0xFF15803D),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedSubjectId = subj.id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_pin_rounded, color: Color(0xFF166534), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Qayyabannoo Toora-Alaa: Barumsi kun bilbila kee irratti kuufameera.',
              style: TextStyle(
                color: Color(0xFF166534),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Yaadannoon toora-alaaf guutummaatti haaromeera!'),
                  backgroundColor: Color(0xFF15803D),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              foregroundColor: const Color(0xFF166534),
            ),
            child: const Text('Haaromsi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(String subjectId, ThemeData theme) {
    final materialsAsync = ref.watch(materialsBySubjectProvider(subjectId));

    return materialsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Dogoggora: $err', style: const TextStyle(color: Colors.red)),
      ),
      data: (materials) {
        // Filter by search query if applicable
        final filtered = _searchQuery.isEmpty
            ? materials
            : materials.where((m) {
                final q = _searchQuery.toLowerCase();
                final t = m.topicTitleOm.toLowerCase();
                final u = m.unitTitleOm.toLowerCase();
                final s = m.summaryContentOm.toLowerCase();
                final f = m.keyFormulasOrRules.any((r) => r.toLowerCase().contains(q));
                return t.contains(q) || u.contains(q) || s.contains(q) || f;
              }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Barnoota kanaaf yaadannoon hin jiru.'
                        : '"$_searchQuery" hin argamne.',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final material = filtered[index];
            return _buildTopicCard(material, theme);
          },
        );
      },
    );
  }

  Widget _buildTopicCard(StudyMaterialModel material, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit & Topic Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Kutaa ${material.unitNumber}',
                    style: const TextStyle(
                      color: Color(0xFF15803D),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    material.unitTitleOm,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              material.topicTitleOm,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              material.summaryContentOm,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
              ),
            ),

            // Key Formulas / Rules (if present)
            if (material.keyFormulasOrRules.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.functions_rounded, size: 16, color: Color(0xFF15803D)),
                        SizedBox(width: 6),
                        Text(
                          'Seera / Foormulaa Bu\'uuraa:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...material.keyFormulasOrRules.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '• $f',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Past Ministry Exam Tips (if present)
            if (material.pastExamTipsOm.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_rounded, size: 18, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gorsa Qormaata Ministeeraa:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            material.pastExamTipsOm,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
