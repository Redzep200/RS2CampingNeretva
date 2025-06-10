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
      print('GetAll response: $body');
      final List data = body['resultList'] ?? [];
      return data.map((e) => Reservation.fromJson(e)).toList();
    } else {
      print('GetAll failed: ${response.statusCode} ${response.body}');
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
      print('Insert failed: ${response.statusCode} ${response.body}');
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }

  static Future<List<Reservation>> getByUserId(
    int userId, {
    int page = 0,
    int pageSize = 4,
    DateTime? checkInDate,
  }) async {
    final headers = await AuthService.getAuthHeaders();

    final queryParams = {
      'UserId': userId.toString(),
      'IsPersonsIncluded': 'true',
      'IsVehicleIncluded': 'true',
      'IsAccommodationIncluded': 'true',
      'IsRentableItemsIncluded': 'true',
      'IsActivitiesIncluded': 'true',
      'IsParcelIncluded': 'true',
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      'OrderBy': 'CheckInDate desc',
    };

    if (checkInDate != null) {
      queryParams['CheckInDate'] = checkInDate.toIso8601String().split('T')[0];
    }

    final uri = Uri.http('10.0.2.2:5205', '/Reservation', queryParams);
    print('Request URL: $uri');
    print('Headers: $headers');
    print('Pagination: Page=$page, PageSize=$pageSize');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      print('GetByUserId response: $body');
      final List data = body['resultList'] ?? [];
      return data.map((e) => Reservation.fromJson(e)).toList();
    } else {
      print('GetByUserId failed: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load reservations for user: ${response.body}');
    }
  }
}
