import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/role_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RoleService {
  static final String _baseUrl = dotenv.env['API_URL']!;

  static Future<List<Role>> fetchAll() async {
    final headers = await AuthService.getAuthHeaders();
    final res = await http.get(Uri.parse('$_baseUrl/Role'), headers: headers);
    final jsonList = json.decode(res.body)['resultList'];
    return List<Role>.from(jsonList.map((x) => Role.fromJson(x)));
  }

  static Future<void> create(Role item) async {
    final headers = await AuthService.getAuthHeaders();
    await http.post(
      Uri.parse('$_baseUrl/Role'),
      headers: headers,
      body: json.encode(item.toJson()),
    );
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Role/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete role');
    }
  }
}
