import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';

class ReservationService {
  static const String _baseUrl = 'http://localhost:5205';

  static Future<List<Reservation>> fetchAll({
    DateTime? from,
    DateTime? to,
  }) async {
    final headers = await AuthService.getAuthHeaders();

    final uri = Uri.http('localhost:5205', '/Reservation', {
      'IsPersonsIncluded': 'true',
      'IsVehicleIncluded': 'true',
      'IsAccommodationIncluded': 'true',
      'IsRentableItemsIncluded': 'true',
      'IsActivitiesIncluded': 'true',
      'IsParcelIncluded': 'true',
      'IsUserIncluded': 'true',
      'PageSize': '1000',
      if (from != null) 'CheckInDate': from.toIso8601String(),
      if (to != null) 'CheckOutDate': to.toIso8601String(),
    });

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body)['resultList'];
      return List<Reservation>.from(
        jsonList.map((x) => Reservation.fromJson(x)),
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

    final uri = Uri.http('localhost:5205', '/Reservation', {
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
