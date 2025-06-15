import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PersonService {
  static String get baseUrl => '${dotenv.env['API_URL']!}/Person';

  static Future<List<PersonType>> getPersons() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['resultList'];
      return data.map((item) => PersonType.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load persons');
    }
  }
}
