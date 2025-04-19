import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person_model.dart';

class PersonService {
  final String baseUrl = 'http://10.0.2.2:5205/Person';

  Future<List<PersonType>> getPersons() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['resultList'];
      return data.map((item) => PersonType.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load persons');
    }
  }
}
