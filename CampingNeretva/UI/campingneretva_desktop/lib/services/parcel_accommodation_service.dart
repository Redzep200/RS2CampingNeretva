import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel_accommodation_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParcelAccommodationService {
  static final String baseUrl = dotenv.env['API_URL']!;

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

  static Future<void> create(ParcelAccommodation acc) async {
    final headers = await AuthService.getAuthHeaders();
    await http.post(
      Uri.parse('$baseUrl/ParcelAccommodation'),
      headers: headers,
      body: json.encode({'parcelAccommodation1': acc.name}),
    );
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
