import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session_model.dart';
import '../providers/schedule_notifier.dart';
import '../providers/schedule_notification_provider.dart';

/// Screen for Grade 8 students to plan and track daily study sessions offline.
/// Completely localized in Afaan Oromoo with Material 3 styling.
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleNotifierProvider);
    final scheduleNotifier = ref.read(scheduleNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sagantaa Qayyabannoo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Yadachiisa Qayyabannoo',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => _showNotificationDialog(context),
          ),
          IconButton(
            tooltip: 'Sagantaa Haaraa Dabali',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showAddSessionModal(context, scheduleNotifier, scheduleState.selectedDay),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Day of Week Horizontal Selector
            _buildDaySelector(scheduleState.selectedDay, scheduleNotifier),

            // 2. Daily Summary Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildDailyProgressCard(scheduleState, theme),
            ),

            // 3. Sessions List
            Expanded(
              child: scheduleState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : scheduleState.sessions.isEmpty
                      ? _buildEmptyState(context, scheduleNotifier, scheduleState.selectedDay)
                      : ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: scheduleState.sessions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final session = scheduleState.sessions[index];
                            return _buildSessionCard(context, session, scheduleNotifier, theme);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF15803D),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Sagantaa Dabali'),
        onPressed: () => _showAddSessionModal(context, scheduleNotifier, scheduleState.selectedDay),
      ),
    );
  }

  Widget _buildDaySelector(DayOfWeekOm selectedDay, ScheduleNotifier notifier) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: DayOfWeekOm.values.length,
        itemBuilder: (context, index) {
          final day = DayOfWeekOm.values[index];
          final isSelected = day == selectedDay;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(
                '${day.shortNameOm}\n${day.nameOm.substring(0, 3)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : null,
                  height: 1.1,
                ),
              ),
              selectedColor: const Color(0xFF15803D),
              backgroundColor: Theme.of(context).chipTheme.backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => notifier.selectDay(day),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyProgressCard(ScheduleState state, ThemeData theme) {
    final percent = (state.completionProgress * 100).toInt();
    final completedCount = state.sessions.where((s) => s.isCompleted).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15803D), Color(0xFF166534)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15803D).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.selectedDay.nameOm} - Qayyabannoo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Xumurame: $completedCount / ${state.sessions.length} • Sa\'aatii: ${state.totalMinutes} daqiiqaa',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: state.sessions.isEmpty ? 0 : state.completionProgress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    StudySessionModel session,
    ScheduleNotifier notifier,
    ThemeData theme,
  ) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sagantaa Haquu'),
            content: Text('Sagantaa "${session.subjectNameOm}" haquu barbaaddaa?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Lakkii')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Haqi', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => notifier.deleteSession(session.id),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: session.isCompleted
                ? const Color(0xFF15803D).withOpacity(0.4)
                : theme.dividerColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          leading: Checkbox(
            value: session.isCompleted,
            activeColor: const Color(0xFF15803D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              if (val != null) {
                notifier.toggleCompleted(session.id, val);
              }
            },
          ),
          title: Text(
            session.subjectNameOm,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              decoration: session.isCompleted ? TextDecoration.lineThrough : null,
              color: session.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                session.topicFocusOm,
                style: TextStyle(
                  fontSize: 13,
                  color: session.isCompleted ? Colors.grey : null,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${session.startTime} (${session.durationMinutes} daq.)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (session.notes != null && session.notes!.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.notes_rounded, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session.notes!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ScheduleNotifier notifier,
    DayOfWeekOm day,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '${day.nameOm} sagantaan hin jiru',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Guyyaa kanaaf barnoota qayyabachuu barbaaddu saganteeffadhu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Sagantaa Jalqabaa Dabali'),
              onPressed: () => _showAddSessionModal(context, notifier, day),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSessionModal(
    BuildContext context,
    ScheduleNotifier notifier,
    DayOfWeekOm currentDay,
  ) {
    final formKey = GlobalKey<FormState>();
    String selectedSubjectId = 'herrega';
    String selectedSubjectName = 'Herrega (Maths)';
    DayOfWeekOm chosenDay = currentDay;
    String startTime = '08:30';
    int duration = 45;
    final topicController = TextEditingController();
    final notesController = TextEditingController();

    final subjects = [
      {'id': 'herrega', 'name': 'Herrega (Mathematics)'},
      {'id': 'afaan_oromoo', 'name': 'Afaan Oromoo'},
      {'id': 'saayinsii_waliigalaa', 'name': 'Saayinsii Waliigalaa (General Science)'},
      {'id': 'saayinsii_hawaasaa', 'name': 'Saayinsii Hawaasaa (Social Studies)'},
      {'id': 'english', 'name': 'Ingiliffa (English)'},
      {'id': 'ifa_boru_aptitude', 'name': 'Ifa Boru - Sammuu-Qara (Aptitude)'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sagantaa Qayyabannoo Haaraa',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedSubjectId,
                        decoration: InputDecoration(
                          labelText: 'Gosa Barnootaa',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: subjects.map((s) {
                          return DropdownMenuItem(
                            value: s['id'],
                            child: Text(s['name']!),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedSubjectId = val;
                              selectedSubjectName = subjects.firstWhere((s) => s['id'] == val)['name']!;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<DayOfWeekOm>(
                        value: chosenDay,
                        decoration: InputDecoration(
                          labelText: 'Guyyaa',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: DayOfWeekOm.values.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text(d.nameOm),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => chosenDay = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: topicController,
                        decoration: InputDecoration(
                          labelText: 'Mata-duree Qayyabannoo (Fkn: Tiwooremii Paayitaagorasii)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Mata-duree galchi' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: startTime,
                              decoration: InputDecoration(
                                labelText: 'Sa\'aatii (Fkn: 08:30)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (val) => startTime = val,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: duration.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Daqiiqaa',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (val) => duration = int.tryParse(val) ?? 45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesController,
                        decoration: InputDecoration(
                          labelText: 'Yaadannoo Dabalataa (Yaada gabaabaa)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              notifier.addSession(
                                subjectId: selectedSubjectId,
                                subjectNameOm: selectedSubjectName,
                                dayOfWeek: chosenDay,
                                startTime: startTime,
                                durationMinutes: duration,
                                topicFocusOm: topicController.text.trim(),
                                notes: notesController.text.trim(),
                              );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sagantaan milkaa\'inaan galmeeffameera!'),
                                  backgroundColor: Color(0xFF15803D),
                                ),
                              );
                            }
                          },
                          child: const Text('Galmeessi', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yadachiisa Qayyabannoo'),
        content: const Text(
          'Yadachiisni guyyaa guyyaa yeroo qayyabannoo keetti toora-alaan (offline) bilbila kee irratti ni dhufa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tole'),
          ),
        ],
      ),
    );
  }
}
