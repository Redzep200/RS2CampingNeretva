import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_type_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserTypeService {
  static String get baseUrl => dotenv.env['API_URL']!;

  Future<List<UserType>> getUserTypes() async {
    final response = await http.get(Uri.parse('$baseUrl/UserType'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List results = body['resultList'];
      return results.map((e) => UserType.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user types');
    }
  }
}
