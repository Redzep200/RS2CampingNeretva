import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campingneretva_mobile/models/rentable_item_model.dart';
import '../services/auth_service.dart';

class RentableItemService {
  static const String baseUrl = "http://10.0.2.2:5205";

  static Future<List<RentableItem>> getAvailable(
    String? from,
    String? to,
  ) async {
    Uri uri;

    if (from != null && to != null) {
      uri = Uri.parse("$baseUrl/RentableItem/available?from=$from&to=$to");
    } else {
      uri = Uri.parse("$baseUrl/RentableItem/available");
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RentableItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load rentable items: ${response.statusCode}");
    }
  }

  static Future<List<RentableItem>> getRecommendedRentableItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/UserPreference/recommended/rentable-items'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RentableItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load recommended rentable items");
    }
  }
}
