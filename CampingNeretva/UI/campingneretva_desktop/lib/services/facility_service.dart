import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/facility_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';

class FacilityService {
  static const String _baseUrl = 'http://localhost:5205';

  static Future<List<Facility>> fetchAll() async {
    final res = await http.get(Uri.parse('$_baseUrl/Facility'));
    final jsonList = json.decode(res.body)['resultList'];
    return List<Facility>.from(jsonList.map((x) => Facility.fromJson(x)));
  }

  static Future<void> create(Facility item) async {
    final headers = await AuthService.getAuthHeaders();
    await http.post(
      Uri.parse('$_baseUrl/Facility'),
      headers: headers,
      body: json.encode(item.toJson()),
    );
  }

  static Future<void> update(Facility facility) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Facility/${facility.id}');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(facility.toUpdateJson()),
    );

    if (response.statusCode != 200) {
      print('Update failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update facility');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Facility/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete facility');
    }
  }
}
