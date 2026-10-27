import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_schema.dart';
import '../models/exam_result_schema.dart';
import '../providers/exam_notifier.dart';
import '../providers/exam_state.dart';
import 'exam_history_screen.dart';


/// Active Exam Screen (Qormaata Kutaa 8ffaa)
/// Implements full offline-first exam engine with countdown timer,
/// progress indicator, Material 3 question/option cards, and Afaan Oromoo localization.
class ExamScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectTitleOm;
  final int durationMinutes;

  const ExamScreen({
    super.key,
    this.subjectId = 'herrega',
    this.subjectTitleOm = 'Herrega (Mathematics)',
    this.durationMinutes = 60,
  });

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  late final ExamNotifierParams _params;

  @override
  void initState() {
    super.initState();
    _params = ExamNotifierParams(
      subjectId: widget.subjectId,
      subjectTitleOm: widget.subjectTitleOm,
      durationMinutes: widget.durationMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final examState = ref.watch(examNotifierProvider(_params));
    final examNotifier = ref.read(examNotifierProvider(_params).notifier);
    final theme = Theme.of(context);

    // If exam is completed, show the result view
    if (examState.status == ExamStatus.completed &&
        examState.finalResult != null) {
      return _buildResultView(context, examState.finalResult!, examState);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              examState.subjectTitleOm,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Qormaata Kutaa 8ffaa (Offline)',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Qormaata Dhiisi',
            icon: const Icon(Icons.close),
            onPressed: () => _showExitConfirmationDialog(context, examNotifier),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context, examState, examNotifier),
      ),
      bottomNavigationBar: examState.status == ExamStatus.inProgress
          ? _buildBottomBar(context, examState, examNotifier)
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    ExamState examState,
    ExamNotifier examNotifier,
  ) {
    if (examState.status == ExamStatus.loading ||
        examState.status == ExamStatus.initial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Gaaffilee Isar irraa fe\'aa jira...',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (examState.status == ExamStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                examState.errorMessage ?? 'Dogoggorri uumameera.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  examNotifier.startExam(
                    subjectId: widget.subjectId,
                    subjectTitleOm: widget.subjectTitleOm,
                    durationMinutes: widget.durationMinutes,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Irra-deebi\'i Yaali'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = examState.currentQuestion;
    if (currentQuestion == null) {
      return const Center(child: Text('Gaaffiin hin jiru'));
    }

    return Column(
      children: [
        // 1. Prominent Countdown Timer at the top
        _buildProminentCountdownTimer(context, examState),

        // 2. Progress Indicator (e.g. "Gaaffii 3 / 40")
        _buildProgressSection(context, examState),

        const Divider(height: 1),

        // 3. Question Text and Selectable Option Cards (Scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildQuestionCard(context, examState, currentQuestion),
                const SizedBox(height: 16),
                _buildOptionsList(
                  context,
                  currentQuestion,
                  examState.currentSelectedOption,
                  examNotifier,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 1. Prominent Countdown Timer Widget
  Widget _buildProminentCountdownTimer(
    BuildContext context,
    ExamState state,
  ) {
    final theme = Theme.of(context);
    final isCritical = state.isTimeCritical;
    final isWarning = state.isTimeWarning;

    Color containerColor;
    Color contentColor;

    if (isCritical) {
      containerColor = theme.colorScheme.errorContainer;
      contentColor = theme.colorScheme.onErrorContainer;
    } else if (isWarning) {
      containerColor = Colors.amber.shade100;
      contentColor = Colors.amber.shade900;
    } else {
      containerColor = theme.colorScheme.primaryContainer;
      contentColor = theme.colorScheme.onPrimaryContainer;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical
              ? theme.colorScheme.error
              : (isWarning ? Colors.amber.shade800 : Colors.transparent),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isCritical ? Icons.alarm_on : Icons.timer,
                color: contentColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Yeroo Hafte:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: contentColor,
                ),
              ),
            ],
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: contentColor,
              fontFamily: 'monospace',
            ),
            child: Text(state.formattedRemainingTime),
          ),
        ],
      ),
    );
  }

  /// 2. Progress Indicator Section (e.g. "Gaaffii 3 / 40")
  Widget _buildProgressSection(BuildContext context, ExamState state) {
    final theme = Theme.of(context);
    final currentNumber = state.currentQuestionIndex + 1;
    final total = state.totalQuestions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Localized progress text
              Text(
                'Gaaffii $currentNumber / $total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              // Answered tracker badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Deebiste: ${state.answeredCount} / $total',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progressFraction,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Question Text Card (Material 3)
  Widget _buildQuestionCard(
    BuildContext context,
    ExamState state,
    Question question,
  ) {
    final theme = Theme.of(context);
    final questionNumber = state.currentQuestionIndex + 1;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Gaaffii #$questionNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Selectable Option Cards (Material 3 Design)
  Widget _buildOptionsList(
    BuildContext context,
    Question question,
    int? selectedOptionIndex,
    ExamNotifier notifier,
  ) {
    final optionLetters = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Column(
      children: List.generate(question.options.length, (index) {
        final option = question.options[index];
        final isSelected = selectedOptionIndex == index;
        final letter = index < optionLetters.length ? optionLetters[index] : '${index + 1}';

        return _buildOptionCard(
          context: context,
          letter: letter,
          optionText: option.text,
          isSelected: isSelected,
          onTap: () {
            notifier.selectCurrentOption(index);
          },
        );
      }),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String letter,
    required String optionText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.7)
            : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            child: Row(
              children: [
                // Option Letter Badge (A, B, C, D)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Option Text
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      height: 1.35,
                    ),
                  ),
                ),

                // Selection checkmark or radio
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom Navigation Bar: "Duubatti" and "Itti fufi" / "Xumuri"
  Widget _buildBottomBar(
    BuildContext context,
    ExamState state,
    ExamNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isLast = state.isLastQuestion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          // "Duubatti" (Previous) button
          if (!state.isFirstQuestion)
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () => notifier.previousQuestion(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Duubatti'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          if (!state.isFirstQuestion) const SizedBox(width: 12),

          // "Itti fufi" (Next) or "Xumuri" (Finish) button
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () {
                if (isLast) {
                  _showFinishConfirmationDialog(context, state, notifier);
                } else {
                  notifier.nextQuestion();
                }
              },
              icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
              // Button text dynamically switches between "Itti fufi" and "Xumuri"
              label: Text(
                isLast ? 'Xumuri' : 'Itti fufi',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isLast
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog confirming if user wants to finish exam early or on last question
  void _showFinishConfirmationDialog(
    BuildContext context,
    ExamState state,
    ExamNotifier notifier,
  ) {
    final answered = state.answeredCount;
    final total = state.totalQuestions;
    final unAnswered = total - answered;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Qormaata Xumuruu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gaaffilee $total keessaa $answered deebisteetta.'),
            if (unAnswered > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Hubachiisa: Gaaffileen $unAnswered hin deebifamne jiru!',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Text('Qormaata xumuruu barbaaddaa?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Lakki, Itti Fufi'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.endExam();
            },
            child: const Text('Eeyyee, Xumuri'),
          ),
        ],
      ),
    );
  }

  /// Dialog when user tries to exit the exam screen
  void _showExitConfirmationDialog(
    BuildContext context,
    ExamNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Qormaata Dhiisuu'),
        content: const Text(
          'Yoo ammaan kana baate, deebiin kee Isar irratti ni kuufama garuu qormaanni ni xumurama. Bahiinsa mirkaneessi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Itti Fufi'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.endExam();
              Navigator.of(context).maybePop();
            },
            child: const Text('Bahi'),
          ),
        ],
      ),
    );
  }

  /// 4. Completed Result View
  Widget _buildResultView(
    BuildContext context,
    ExamResult result,
    ExamState state,
  ) {
    final theme = Theme.of(context);
    final percentage = result.scorePercentage;
    final isPassed = result.isPassed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bu\'aa Qormaataa'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isPassed
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isPassed ? Colors.green : Colors.orange,
                  width: 3,
                ),
              ),
              child: Icon(
                isPassed ? Icons.emoji_events : Icons.refresh,
                size: 50,
                color: isPassed ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              isPassed
                  ? 'Baga Gammaddan! Qormaata Darbiteetta!'
                  : 'Cimi Yaali! Irra-deebi\'ii Qo\'adhu!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.subjectTitleOm,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Score Highlight Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Text(
                      '${result.score} / ${result.totalQuestions}',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: isPassed ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          'Yeroo Fudhatte',
                          result.formattedTimeTaken,
                          Icons.timer_outlined,
                        ),
                        _buildStatColumn(
                          'Haala Isar',
                          result.isSynced ? 'Synced' : 'Offline (isSynced: false)',
                          Icons.cloud_off,
                          highlightOffline: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              icon: const Icon(Icons.home),
              label: const Text('Gara Fuula Duraatti Deebi\'i'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(examNotifierProvider(_params).notifier)
                    .startExam(
                      subjectId: widget.subjectId,
                      subjectTitleOm: widget.subjectTitleOm,
                      durationMinutes: widget.durationMinutes,
                    );
              },
              icon: const Icon(Icons.replay),
              label: const Text('Irra-deebi\'ii Qori'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExamHistoryScreen()),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Seenaa Qormaataa Daawwadhu (History)'),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon, {
    bool highlightOffline = false,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: highlightOffline ? Colors.orange.shade800 : null,
          ),
        ),
      ],
    );
  }
}
