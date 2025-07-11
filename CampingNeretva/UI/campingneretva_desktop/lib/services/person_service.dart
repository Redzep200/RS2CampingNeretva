import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PersonService {
  static final String _baseUrl = dotenv.env['API_URL']!;

  static Future<List<PersonType>> fetchAll() async {
    final res = await http.get(Uri.parse('$_baseUrl/Person'));
    final jsonList = json.decode(res.body)['resultList'];
    return List<PersonType>.from(jsonList.map((x) => PersonType.fromJson(x)));
  }

  static Future<void> create(PersonType item) async {
    final headers = await AuthService.getAuthHeaders();
    await http.post(
      Uri.parse('$_baseUrl/Person'),
      headers: headers,
      body: json.encode(item.toJson()),
    );
  }

  static Future<void> update(PersonType person) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Person/${person.id}');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(person.toUpdateJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update person');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Person/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete person');
    }
  }
}
