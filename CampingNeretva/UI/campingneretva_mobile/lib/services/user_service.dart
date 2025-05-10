import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  static const String baseUrl = 'http://192.168.0.15:5205';

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
}
