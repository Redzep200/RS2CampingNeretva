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
    try {
      final headers = await AuthService.getAuthHeaders();
      final user = AuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print(
        'Creating PayPal order for reservation: $reservationId, amount: $amount',
      );

      final response = await http.post(
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
      );

      print('Create order response status: ${response.statusCode}');
      print('Create order response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to create PayPal order: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating PayPal order: $e');
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

      print('Capturing PayPal order: $orderId for reservation: $reservationId');

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
          .timeout(
            const Duration(seconds: 30), // Add timeout
            onTimeout: () {
              throw Exception('Payment capture request timed out');
            },
          );

      print('Capture response status: ${response.statusCode}');
      print('Capture response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        print('Payment capture result: $result');
        return result;
      } else {
        throw Exception(
          'Failed to capture PayPal payment: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error capturing PayPal payment: $e');
      rethrow;
    }
  }
}
