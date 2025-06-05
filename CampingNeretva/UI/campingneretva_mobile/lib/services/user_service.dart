import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserService {
  static const String baseUrl = 'http://10.0.2.2:5205';

  Future<User> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/User/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<List<User>> getAll({bool includeUserType = false}) async {
    final query = includeUserType ? '?IsUserTypeIncluded=true' : '';
    final response = await http.get(Uri.parse('$baseUrl/User$query'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List results = body['resultList'];
      return results.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<User?> updateOwnProfile({
    String? username,
    String? email,
    String? phoneNumber,
    String? password,
    String? passwordConfirmation,
  }) async {
    final headers = await AuthService.getAuthHeaders();

    Map<String, dynamic> body = {};
    if (username != null && username.isNotEmpty) body['userName'] = username;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phoneNumber != null && phoneNumber.isNotEmpty)
      body['phoneNumber'] = phoneNumber;
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
      body['passwordConfirmation'] = passwordConfirmation ?? '';
    }

    final response = await http.put(
      Uri.parse('$baseUrl/User/me'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      AuthService.currentUser = user;
      return user;
    } else {
      print('Update failed: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
