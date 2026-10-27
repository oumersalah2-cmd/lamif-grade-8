import 'package:flutter/material.dart';

/// Payment verification status matching the backend Prisma PaymentStatus enum
enum PaymentStatus {
  /// Receipt submitted and awaiting admin verification
  pending,

  /// Payment verified, full access granted
  verified,

  /// Payment rejected due to invalid/blurry screenshot
  rejected;

  /// Display text in Afaan Oromoo
  String get titleOm {
    switch (this) {
      case PaymentStatus.pending:
        return 'Qoratamaa Jira (Pending)';
      case PaymentStatus.verified:
        return "Mirkanaa'eera (Verified)";
      case PaymentStatus.rejected:
        return "Kufaa Ta'eera (Rejected)";
    }
  }

  /// Display description in Afaan Oromoo
  String get descriptionOm {
    switch (this) {
      case PaymentStatus.pending:
        return 'Nagaheen kaffaltii keessanii qoratamaa jira. Yeroo gabaabaa keessatti qormaanni hundi isiniif banama.';
      case PaymentStatus.verified:
        return 'Kaffaltiin keessan mirkanaa\'eera! Qormaata hunda fayyadamuu dandeessu.';
      case PaymentStatus.rejected:
        return 'Nagaheen kaffaltii keessanii hin mirkanoofne. Maaloo nagahee sirrii ta\'e irra deebi\'aa fe\'aa.';
    }
  }

  /// Status badge color
  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return const Color(0xFFD97706); // Amber
      case PaymentStatus.verified:
        return const Color(0xFF16A34A); // Emerald Green
      case PaymentStatus.rejected:
        return const Color(0xFFDC2626); // Red
    }
  }

  /// Status badge background color
  Color get backgroundColor {
    switch (this) {
      case PaymentStatus.pending:
        return const Color(0xFFFEF3C7);
      case PaymentStatus.verified:
        return const Color(0xFFDCFCE7);
      case PaymentStatus.rejected:
        return const Color(0xFFFEE2E2);
    }
  }

  /// Status icon
  IconData get icon {
    switch (this) {
      case PaymentStatus.pending:
        return Icons.hourglass_top_rounded;
      case PaymentStatus.verified:
        return Icons.verified_rounded;
      case PaymentStatus.rejected:
        return Icons.error_outline_rounded;
    }
  }

  /// Maps to backend Prisma enum string
  String get prismaValue {
    switch (this) {
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.verified:
        return 'VERIFIED';
      case PaymentStatus.rejected:
        return 'REJECTED';
    }
  }

  /// Parse from string (handles 'PENDING', 'pending', etc.)
  static PaymentStatus fromString(String? value) {
    if (value == null) return PaymentStatus.pending;
    final upper = value.toUpperCase();
    if (upper == 'VERIFIED') return PaymentStatus.verified;
    if (upper == 'REJECTED') return PaymentStatus.rejected;
    return PaymentStatus.pending;
  }
}
