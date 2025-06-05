import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campingneretva_mobile/services/auth_service.dart';

class PaymentService {
  static const String baseUrl = 'http://10.0.2.2:5205';

  static Future<Map<String, dynamic>> createPayPalOrder({
    required int reservationId,
    required double amount,
    String currency = 'EUR',
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final user = AuthService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/Payment/create-paypal-order'),
      headers: headers,
      body: jsonEncode({
        'reservationId': reservationId,
        'userId': user.id,
        'amount': amount,
        'currency': currency,
        'returnUrl': 'https://your-app.com/payment/success',
        'cancelUrl': 'https://your-app.com/payment/cancel',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create PayPal order: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> capturePayPalOrder({
    required String orderId,
    required int reservationId,
  }) async {
    final user = AuthService.currentUser;
    final headers = await AuthService.getAuthHeaders();
    if (user == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/Payment/capture-paypal-order'),
      headers: headers,
      body: jsonEncode({
        'orderId': orderId,
        'reservationId': reservationId,
        'userId': user.id,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to capture PayPal payment: ${response.body}');
    }
  }
}
