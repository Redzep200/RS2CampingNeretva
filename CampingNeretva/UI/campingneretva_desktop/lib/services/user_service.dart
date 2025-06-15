import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  static final String _baseUrl = dotenv.env['API_URL']!;

  Future<User> getById(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/User/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<List<User>> getAll({bool includeUserType = false}) async {
    final headers = await AuthService.getAuthHeaders();
    final query = includeUserType ? '?IsUserTypeIncluded=true' : '';
    final response = await http.get(
      Uri.parse('$_baseUrl/User$query'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List results = body['resultList'];
      return results.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> insertUser(Map<String, dynamic> request) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/User'),
      headers: headers,
      body: jsonEncode(request),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to insert user: ${response.body}');
    }
  }

  Future<List<User>> getAllPaginated({
    int page = 1,
    int pageSize = 10,
    String? username,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final queryParams = {
      'Page': '$page',
      'PageSize': '$pageSize',
      'IsUserTypeIncluded': 'true',
      if (username != null && username.isNotEmpty) 'UserName': username,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await http.get(
      Uri.parse('$_baseUrl/User?$queryString'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List results = body['resultList'];
      return results.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deleteUser(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/User/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }
}
