import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel_type_model.dart';
import '../services/auth_service.dart';

class ParcelTypeService {
  static const String baseUrl = "http://localhost:5205";

  static Future<List<ParcelType>> fetchAll() async {
    final response = await http.get(Uri.parse('$baseUrl/ParcelType'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List items = jsonData['resultList'];
      return items.map((e) => ParcelType.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load parcel types');
    }
  }

  static Future<void> create(ParcelType data) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/ParcelType'),
      headers: headers,
      body: json.encode(data.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create parcel type');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/ParcelType/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete parcel type');
    }
  }
}
