import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation_model.dart';
import '../services/auth_service.dart';

class ReservationService {
  static const String baseUrl = "http://10.0.2.2:5205";

  static Future<List<Reservation>> getAll() async {
    final uri = Uri.parse('$baseUrl/Reservation?includeRelated=true');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['resultList'];
      return data.map((e) => Reservation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load reservations');
    }
  }

  static Future<Map<String, dynamic>> insert(
    Map<String, dynamic> payload,
  ) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/Reservation'),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }

  static Future<List<Reservation>> getByUserId(int userId) async {
    final headers = await AuthService.getAuthHeaders();

    final uri = Uri.http('10.0.2.2:5205', '/Reservation', {
      'UserId': userId.toString(),
      'IsPersonsIncluded': 'true',
      'IsVehicleIncluded': 'true',
      'IsAccommodationIncluded': 'true',
      'IsRentableItemsIncluded': 'true',
      'IsActivitiesIncluded': 'true',
      'IsParcelIncluded': 'true',
    });

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['resultList'];
      return data.map((e) => Reservation.fromJson(e)).toList();
    } else {
      print(
        'Reservation fetch failed: ${response.statusCode} ${response.body}',
      );
      throw Exception('Failed to load reservations for user');
    }
  }
}
