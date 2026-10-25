import 'package:flutter/material.dart';
import '../models/student_track.dart';

/// Elevated Material 3 Selection Card designed for academic clarity & high touch precision.
class TrackSelectionCard extends StatelessWidget {
  final StudentTrack track;
  final bool isSelected;
  final VoidCallback onSelected;

  const TrackSelectionCard({
    Key? key,
    required this.track,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBoth = track == StudentTrack.both;

    // Academic Trust Colors (Deep Blue/Green palette)
    final primaryAccent = track.accentColor;
    final borderColor = isSelected
        ? primaryAccent
        : const Color(0xFFE2E8F0);
    final cardBg = isSelected
        ? primaryAccent.withOpacity(0.04)
        : Colors.white;

    return Semantics(
      selected: isSelected,
      button: true,
      label: '${track.titleOm}, ${track.subtitle}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryAccent.withOpacity(0.12),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    offset: const Offset(0, 3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onSelected,
            borderRadius: BorderRadius.circular(20),
            splashColor: primaryAccent.withOpacity(0.08),
            highlightColor: primaryAccent.withOpacity(0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon, Badge, and Selection Radio Indicator
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Elevated Circular Icon Container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryAccent
                              : primaryAccent.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          track.icon,
                          size: 26,
                          color: isSelected ? Colors.white : primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (track.badgeText != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: isBoth
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isBoth
                                        ? const Color(0xFF81C784)
                                        : const Color(0xFF93C5FD),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  track.badgeText!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    color: isBoth
                                        ? const Color(0xFF1B5E20)
                                        : const Color(0xFF1E40AF),
                                  ),
                                ),
                              ),
                            ],
                            Text(
                              track.titleOm,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A), // Slate 900
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              track.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569), // Slate 600
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selection Radio / Checkbox Indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? primaryAccent : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? primaryAccent
                                : const Color(0xFFCBD5E1),
                            width: isSelected ? 0 : 2,
                          ),
                        ),
                        child: isSelected
                            ? const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Divider
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isSelected
                        ? primaryAccent.withOpacity(0.12)
                        : const Color(0xFFF1F5F9),
                  ),

                  const SizedBox(height: 12),

                  // Afaan Oromoo Description
                  Text(
                    track.descriptionOm,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.5,
                      height: 1.45,
                      color: const Color(0xFF334155), // Slate 700
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
