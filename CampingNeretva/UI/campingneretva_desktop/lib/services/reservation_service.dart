import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReservationService {
  static final String _baseUrl = dotenv.env['API_URL']!;

  static Future<List<Reservation>> fetchAll({
    DateTime? from,
    DateTime? to,
    int page = 0,
    int pageSize = 10,
    String? username,
    String? reservationNumber,
    String? vehicleType,
    DateTime? date,
  }) async {
    final headers = await AuthService.getAuthHeaders();

    final queryParams = {
      'IsPersonsIncluded': 'true',
      'IsVehicleIncluded': 'true',
      'IsAccommodationIncluded': 'true',
      'IsRentableItemsIncluded': 'true',
      'IsActivitiesIncluded': 'true',
      'IsParcelIncluded': 'true',
      'IsUserIncluded': 'true',
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      if (from != null) 'CheckInDate': from.toIso8601String(),
      if (to != null) 'CheckOutDate': to.toIso8601String(),
      if (username != null && username.isNotEmpty) 'Username': username,
      if (reservationNumber != null && reservationNumber.isNotEmpty)
        'ReservationNumber': reservationNumber,
      if (vehicleType != null) 'VehicleType': vehicleType,
      if (date != null) 'CheckInDate': date.toIso8601String(),
    };

    final uri = Uri.parse(
      '$_baseUrl/Reservation',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return List<Reservation>.from(
        jsonBody['resultList'].map((x) => Reservation.fromJson(x)),
      );
    } else {
      throw Exception('Failed to fetch all reservations');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Reservation/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete reservation');
    }
  }

  static Future<List<Reservation>> getByUserId(int userId) async {
    final headers = await AuthService.getAuthHeaders();

    final uri = Uri.parse('$_baseUrl/Reservation').replace(
      queryParameters: {
        'UserId': userId.toString(),
        'IsPersonsIncluded': 'true',
        'IsVehicleIncluded': 'true',
        'IsAccommodationIncluded': 'true',
        'IsRentableItemsIncluded': 'true',
        'IsActivitiesIncluded': 'true',
        'IsParcelIncluded': 'true',
      },
    );

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
