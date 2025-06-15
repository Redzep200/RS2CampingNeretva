import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel_accommodation_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParcelAccommodationService {
  static String get baseUrl => dotenv.env['API_URL']!;

  Future<List<ParcelAccommodation>> getAccommodations() async {
    final response = await http.get(Uri.parse('$baseUrl/ParcelAccommodation'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List items = jsonData['resultList'];
      return items.map((e) => ParcelAccommodation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load parcel accommodations');
    }
  }
}
