import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/exam_timer.dart';

class ExamTimerBadge extends ConsumerWidget {
  final ExamTimerParams timerParams;
  final bool showProgressIndicator;
  final bool allowPause;

  const ExamTimerBadge({
    Key? key,
    required this.timerParams,
    this.showProgressIndicator = true,
    this.allowPause = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(examTimerProvider(timerParams));
    final timerNotifier = ref.read(examTimerProvider(timerParams).notifier);

    final Color badgeColor = timerState.isCritical
        ? const Color(0xFFDC2626) // Red (< 1 min)
        : timerState.isWarning
            ? const Color(0xFFD97706) // Amber (< 5 min)
            : const Color(0xFF1B6E32); // Standard green

    final Color backgroundColor = badgeColor.withOpacity(0.12);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pause/Play Toggle Button (optional)
            if (allowPause)
              IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  timerState.status == ExamTimerStatus.paused
                      ? Icons.play_arrow
                      : Icons.pause,
                  color: badgeColor,
                ),
                onPressed: () {
                  if (timerState.status == ExamTimerStatus.paused) {
                    timerNotifier.resume();
                  } else {
                    timerNotifier.pause();
                  }
                },
              ),

            if (allowPause) const SizedBox(width: 6),

            // Timer Pill Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: timerState.isCritical
                      ? const Color(0xFFDC2626)
                      : Colors.transparent,
                  width: timerState.isCritical ? 1.5 : 0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: 15,
                    color: badgeColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    timerState.formattedTime,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Optional Progress Indicator
        if (showProgressIndicator) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: timerState.progressRatio,
                minHeight: 3,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
