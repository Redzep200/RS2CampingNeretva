import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campingneretva_mobile/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  static String get baseUrl => dotenv.env['API_URL']!;

  static Future<Map<String, dynamic>> createPayPalOrder({
    required int reservationId,
    required double amount,
    String currency = 'EUR',
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final user = AuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await http
          .post(
            Uri.parse('$baseUrl/Payment/create-paypal-order'),
            headers: headers,
            body: jsonEncode({
              'reservationId': reservationId,
              'userId': user.id,
              'amount': amount,
              'currency': currency,
              'returnUrl': 'myapp://paypal-success',
              'cancelUrl': 'myapp://paypal-cancel',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        if (result['orderId'] == null || result['approvalUrl'] == null) {
          throw Exception('Invalid PayPal order response');
        }
        return result;
      } else {
        throw Exception('Failed to create PayPal order: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> capturePayPalOrder({
    required String orderId,
    required int reservationId,
  }) async {
    try {
      final user = AuthService.currentUser;
      final headers = await AuthService.getAuthHeaders();
      if (user == null) throw Exception('User not authenticated');

      final response = await http
          .post(
            Uri.parse('$baseUrl/Payment/capture-paypal-order'),
            headers: headers,
            body: jsonEncode({
              'orderId': orderId,
              'reservationId': reservationId,
              'userId': user.id,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        if (result['status'] == null) {
          throw Exception('Invalid capture response');
        }
        return result;
      } else {
        throw Exception('Failed to capture PayPal payment: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
