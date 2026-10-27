import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/payment_status.dart';
import '../models/student_track.dart';

/// Result returned from register-payment API
class PaymentRegistrationResult {
  final bool success;
  final String message;
  final String? userId;
  final PaymentStatus status;
  final String? receiptUrl;

  const PaymentRegistrationResult({
    required this.success,
    required this.message,
    this.userId,
    this.status = PaymentStatus.pending,
    this.receiptUrl,
  });
}

class PaymentService {
  final http.Client _client;
  final String _baseUrl;

  PaymentService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _resolveDefaultBaseUrl();

  static String _resolveDefaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:5000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
  }

  /// Sends multipart request to POST /api/v1/auth/register-payment with screenshot receipt
  Future<PaymentRegistrationResult> registerPayment({
    required String name,
    required String phone,
    required String schoolZone,
    String? schoolName,
    required StudentTrack track,
    required XFile receiptImage,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/register-payment');
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['schoolZone'] = schoolZone;
    if (schoolName != null && schoolName.isNotEmpty) {
      request.fields['schoolName'] = schoolName;
    }
    request.fields['selectedTrack'] = track.prismaValue;
    request.fields['amountPaid'] = track.priceEtb.toString();

    // Attach receipt image file
    final bytes = await receiptImage.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'receipt',
      bytes,
      filename: receiptImage.name.isNotEmpty ? receiptImage.name : 'receipt.jpg',
    );
    request.files.add(multipartFile);

    try {
      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
        final userData = data['data'] as Map<String, dynamic>?;
        return PaymentRegistrationResult(
          success: true,
          message: data['message'] as String? ?? 'Nagaheen kaffaltii milkaa\'inaan ergameera.',
          userId: userData?['userId'] as String?,
          status: PaymentStatus.fromString(userData?['paymentStatus'] as String?),
          receiptUrl: userData?['paymentReceiptUrl'] as String?,
        );
      } else {
        return PaymentRegistrationResult(
          success: false,
          message: data['message'] as String? ?? 'Erguun hin danda\'amne. Maaloo irra deebi\'aa yaalaa.',
        );
      }
    } catch (e) {
      debugPrint('Error registering payment: $e');
      return PaymentRegistrationResult(
        success: false,
        message: 'Dogoggora qunnamtii: Maaloo intarneetii keessan mirkaneeffadhaa ($e)',
      );
    }
  }

  /// Queries GET /api/v1/auth/payment-status to check if admin has verified the student
  Future<PaymentStatus> checkPaymentStatus(String phone) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/payment-status?phone=${Uri.encodeComponent(phone)}');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          final statusStr = body['data']['paymentStatus'] as String?;
          return PaymentStatus.fromString(statusStr);
        }
      }
    } catch (e) {
      debugPrint('Error checking payment status: $e');
    }
    return PaymentStatus.pending;
  }
}
