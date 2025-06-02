import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_type_model.dart';
import '../services/auth_service.dart';

class UserTypeService {
  static const String baseUrl = "http://localhost:5205";

  Future<List<UserType>> getUserTypes() async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/UserType'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List results = body['resultList'];
      return results.map((e) => UserType.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user types');
    }
  }
}
