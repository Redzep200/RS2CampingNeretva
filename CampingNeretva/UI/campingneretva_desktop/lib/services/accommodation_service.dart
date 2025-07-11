import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accommodation_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccommodationService {
  static final String baseUrl = dotenv.env['API_URL']!;

  static Future<List<Accommodation>> fetchAll() async {
    final response = await http.get(Uri.parse('$baseUrl/Accommodation'));
    if (response.statusCode == 200) {
      final list = json.decode(response.body)['resultList'];
      return List<Accommodation>.from(
        list.map((e) => Accommodation.fromJson(e)),
      );
    } else {
      throw Exception('Failed to load accommodations');
    }
  }

  static Future<void> create(Accommodation data) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/Accommodation'),
      headers: headers,
      body: json.encode(data.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create accommodation');
    }
  }

  static Future<void> update(Accommodation accommodation) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/Accommodation/${accommodation.id}');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(accommodation.toUpdateJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update accommodation');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/Accommodation/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete accommodation');
    }
  }
}
