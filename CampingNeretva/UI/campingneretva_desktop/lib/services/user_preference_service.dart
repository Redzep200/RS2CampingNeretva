import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_preference_model.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserPreferenceService {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<UserPreferenceModel> getByUserId(int userId) async {
    final headers = await AuthService.getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/UserPreference/$userId');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserPreferenceModel.fromJson(json);
    } else {
      throw Exception('Failed to load user preferences: ${response.body}');
    }
  }
}
