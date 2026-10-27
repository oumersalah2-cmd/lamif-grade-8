import 'payment_status.dart';
import 'student_track.dart';

class AuthUser {
  final String uid;
  final String phoneNumber;
  final String? fullName;
  final String? schoolName;
  final String? zoneName;
  final String? backendToken;
  final bool isVerified; // Phone verification
  final PaymentStatus paymentStatus; // Payment verification status (PENDING, VERIFIED, REJECTED)
  final StudentTrack? selectedTrack;
  final String? paymentReceiptUrl;
  final double? amountPaid;
  final DateTime? createdAt;

  const AuthUser({
    required this.uid,
    required this.phoneNumber,
    this.fullName,
    this.schoolName,
    this.zoneName,
    this.backendToken,
    this.isVerified = false,
    this.paymentStatus = PaymentStatus.pending,
    this.selectedTrack,
    this.paymentReceiptUrl,
    this.amountPaid,
    this.createdAt,
  });

  /// True if student has been fully verified and paid
  bool get hasPaidAccess => paymentStatus == PaymentStatus.verified;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'] as String? ?? json['userId'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String?,
      schoolName: json['schoolName'] as String?,
      zoneName: json['zoneName'] as String? ?? json['schoolZone'] as String?,
      backendToken: json['token'] as String? ?? json['backendToken'] as String?,
      isVerified: json['isVerified'] as bool? ?? true,
      paymentStatus: PaymentStatus.fromString(json['paymentStatus'] as String?),
      selectedTrack: json['selectedTrack'] != null
          ? StudentTrack.fromStorageValue(json['selectedTrack'] as String?)
          : null,
      paymentReceiptUrl: json['paymentReceiptUrl'] as String?,
      amountPaid: (json['amountPaid'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
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
      'paymentStatus': paymentStatus.prismaValue,
      'selectedTrack': selectedTrack?.storageValue,
      'paymentReceiptUrl': paymentReceiptUrl,
      'amountPaid': amountPaid,
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
    PaymentStatus? paymentStatus,
    StudentTrack? selectedTrack,
    String? paymentReceiptUrl,
    double? amountPaid,
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
      paymentStatus: paymentStatus ?? this.paymentStatus,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      paymentReceiptUrl: paymentReceiptUrl ?? this.paymentReceiptUrl,
      amountPaid: amountPaid ?? this.amountPaid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
