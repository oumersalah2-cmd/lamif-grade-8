class AuthUser {
  final String uid;
  final String phoneNumber;
  final String? fullName;
  final String? schoolName;
  final String? zoneName;
  final String? backendToken;
  final bool isVerified;
  final DateTime? createdAt;

  const AuthUser({
    required this.uid,
    required this.phoneNumber,
    this.fullName,
    this.schoolName,
    this.zoneName,
    this.backendToken,
    this.isVerified = false,
    this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'] as String,
      phoneNumber: json['phoneNumber'] as String,
      fullName: json['fullName'] as String?,
      schoolName: json['schoolName'] as String?,
      zoneName: json['zoneName'] as String?,
      backendToken: json['token'] as String? ?? json['backendToken'] as String?,
      isVerified: json['isVerified'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'schoolName': schoolName,
      'zoneName': zoneName,
      'backendToken': backendToken,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  AuthUser copyWith({
    String? uid,
    String? phoneNumber,
    String? fullName,
    String? schoolName,
    String? zoneName,
    String? backendToken,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      schoolName: schoolName ?? this.schoolName,
      zoneName: zoneName ?? this.zoneName,
      backendToken: backendToken ?? this.backendToken,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
