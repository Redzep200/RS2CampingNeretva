import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel_accommodation_model.dart';
import '../services/auth_service.dart';

class ParcelAccommodationService {
  static const String baseUrl = "http://localhost:5205";

  static Future<List<ParcelAccommodation>> fetchAll() async {
    final response = await http.get(Uri.parse('$baseUrl/ParcelAccommodation'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List items = jsonData['resultList'];
      return items.map((e) => ParcelAccommodation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load parcel accommodations');
    }
  }

  static Future<void> create(ParcelAccommodation data) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/ParcelAccommodation'),
      headers: headers,
      body: json.encode(data.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create parcel accommodation');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/ParcelAccommodation/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete parcel accommodation');
    }
  }
}
