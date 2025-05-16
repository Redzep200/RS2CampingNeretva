import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';

class VehicleService {
  static const String _baseUrl = 'http://localhost:5205';

  static Future<List<Vehicle>> fetchAll() async {
    final res = await http.get(Uri.parse('$_baseUrl/Vehicle'));
    final jsonList = json.decode(res.body)['resultList'];
    return List<Vehicle>.from(jsonList.map((x) => Vehicle.fromJson(x)));
  }

  static Future<void> create(Vehicle item) async {
    final headers = await AuthService.getAuthHeaders();
    await http.post(
      Uri.parse('$_baseUrl/Vehicle'),
      headers: headers,
      body: json.encode(item.toJson()),
    );
  }

  static Future<void> update(Vehicle vehicle) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Vehicle/${vehicle.id}');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(vehicle.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update vehicle');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Vehicle/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete vehicle');
    }
  }
}
