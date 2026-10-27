import 'package:flutter/material.dart';
import '../../exams/models/question_schema.dart';
import '../models/search_result_item.dart';

/// Modal dialog or bottom sheet for viewing full Question details,
/// options, and Afaan Oromoo explanation directly from search results.
class QuestionDetailModal extends StatelessWidget {
  final Question question;
  final String subjectTitleOm;

  const QuestionDetailModal({
    Key? key,
    required this.question,
    required this.subjectTitleOm,
  }) : super(key: key);

  static void show(BuildContext context, Question question, String subjectTitleOm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuestionDetailModal(
        question: question,
        subjectTitleOm: subjectTitleOm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Subject Tag & Close Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subjectTitleOm,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question Text
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Options List (A, B, C, D)
            const Text(
              'Filannoowwan (Options):',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),

            ...question.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final opt = entry.value;
              final letter = String.fromCharCode(65 + idx); // A, B, C, D

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: opt.isCorrect
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: opt.isCorrect
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFE2E8F0),
                    width: opt.isCorrect ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: opt.isCorrect
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: opt.isCorrect ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: opt.isCorrect ? FontWeight.bold : FontWeight.normal,
                          color: opt.isCorrect
                              ? const Color(0xFF14532D)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (opt.isCorrect) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                    ],
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Explanation Section in Afaan Oromoo
            if (question.explanation.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF1D4ED8)),
                        SizedBox(width: 6),
                        Text(
                          'Ibsa Deebii Sirrii (Explanation)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      question.explanation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Cufi (Close)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
