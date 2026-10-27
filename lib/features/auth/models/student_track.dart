import 'package:flutter/material.dart';

/// Represents the student's chosen academic preparation track in Oromia.
enum StudentTrack {
  /// Standard Grade 8 Regional Exam Prep
  ministryOnly,

  /// Special Boarding School Entrance Exam Prep (Ifa Boru)
  ifaBoruOnly,

  /// Combined Preparation for both exams
  both;

  /// Display title in Afaan Oromoo
  String get titleOm {
    switch (this) {
      case StudentTrack.ministryOnly:
        return 'Qormaata Ministeeraa Qofa';
      case StudentTrack.ifaBoruOnly:
        return 'Qormaata Ifa Boruu Qofa';
      case StudentTrack.both:
        return 'Lachuu';
    }
  }

  /// Official academic subtitle
  String get subtitle {
    switch (this) {
      case StudentTrack.ministryOnly:
        return 'Standard Grade 8 Regional Exam Prep';
      case StudentTrack.ifaBoruOnly:
        return 'Special Boarding School Entrance Exam Prep';
      case StudentTrack.both:
        return 'Prepare for both exams';
    }
  }

  /// Price in Ethiopian Birr (ETB)
  int get priceEtb {
    switch (this) {
      case StudentTrack.ministryOnly:
        return 200;
      case StudentTrack.ifaBoruOnly:
        return 200;
      case StudentTrack.both:
        return 300;
    }
  }

  /// Price display string
  String get priceDisplay => '$priceEtb ETB';

  /// Exact title with price formatted for UI
  String get titleWithPrice => '$titleOm ($priceDisplay)';

  /// Maps to remote PostgreSQL / Prisma enum
  String get prismaValue {
    switch (this) {
      case StudentTrack.ministryOnly:
        return 'MINISTRY_ONLY';
      case StudentTrack.ifaBoruOnly:
        return 'IFA_BORU_ONLY';
      case StudentTrack.both:
        return 'BOTH';
    }
  }

  /// Detailed description in Afaan Oromoo for student guidance
  String get descriptionOm {
    switch (this) {
      case StudentTrack.ministryOnly:
        return 'Qophii qormaata naannoo Oromiyaa kutaa 8ffaa qofaaf kan qophaa\'e. Barnoota 7n hunda of keessatti qabata.';
      case StudentTrack.ifaBoruOnly:
        return 'Qormaata seensa manneen barumsaa bultii addaa Ifa Boruu (Special Boarding School)tiif addatti kan qophaa\'e.';
      case StudentTrack.both:
        return 'Qormaata Ministeeraa fi Ifa Boruu yeroo tokkotti walfaana qophaa\'uuf. (Filatamaa)';
    }
  }

  /// Academic icon representing the track
  IconData get icon {
    switch (this) {
      case StudentTrack.ministryOnly:
        return Icons.school_rounded;
      case StudentTrack.ifaBoruOnly:
        return Icons.auto_awesome_rounded;
      case StudentTrack.both:
        return Icons.workspace_premium_rounded;
    }
  }

  /// Visual theme accent color for each track card
  Color get accentColor {
    switch (this) {
      case StudentTrack.ministryOnly:
        return const Color(0xFF0F3D3E); // Deep Academic Forest
      case StudentTrack.ifaBoruOnly:
        return const Color(0xFF1E3A8A); // Deep Trustworthy Navy Blue
      case StudentTrack.both:
        return const Color(0xFF1B6E32); // Vibrant Growth Green
    }
  }

  /// Optional badge text for highlighted tracks
  String? get badgeText {
    switch (this) {
      case StudentTrack.both:
        return 'Filatamaa (Recommended)';
      case StudentTrack.ifaBoruOnly:
        return 'Addaa (Special)';
      case StudentTrack.ministryOnly:
        return 'Idilee (Standard)';
    }
  }

  /// String value for local storage persistence (SharedPreferences / Isar)
  String get storageValue {
    switch (this) {
      case StudentTrack.ministryOnly:
        return 'ministry_only';
      case StudentTrack.ifaBoruOnly:
        return 'ifa_boru_only';
      case StudentTrack.both:
        return 'both';
    }
  }

  /// Parses a stored string value back to the enum, defaulting safely
  static StudentTrack fromStorageValue(String? value) {
    if (value == null) return StudentTrack.both;
    for (final track in StudentTrack.values) {
      if (track.storageValue == value || track.name == value) {
        return track;
      }
    }
    return StudentTrack.both;
  }
}
