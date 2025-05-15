import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person_model.dart';

class PersonService {
  static const String _baseUrl = 'http://localhost:5205';

  static Future<List<PersonType>> fetchAll() async {
    final res = await http.get(Uri.parse('$_baseUrl/Person'));
    final jsonList = json.decode(res.body)['resultList'];
    return List<PersonType>.from(jsonList.map((x) => PersonType.fromJson(x)));
  }

  static Future<void> create(PersonType item) async {
    await http.post(
      Uri.parse('$_baseUrl/Person'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
  }

  static Future<void> update(PersonType person) async {
    final url = Uri.parse('$_baseUrl/Person/${person.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update person');
    }
  }

  static Future<void> delete(int id) async {
    await http.delete(Uri.parse('$_baseUrl/Person/$id'));
  }
}
