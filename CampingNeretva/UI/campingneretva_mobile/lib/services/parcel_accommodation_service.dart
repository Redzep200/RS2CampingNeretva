import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel_accommodation_model.dart';

class ParcelAccommodationService {
  static const String baseUrl = "http://10.0.2.2:5205";

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
