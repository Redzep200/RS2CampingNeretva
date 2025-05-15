import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_type_model.dart';

class UserTypeService {
  static const String baseUrl = "http://10.0.2.2:5205";

  Future<List<UserType>> getWorkers() async {
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
