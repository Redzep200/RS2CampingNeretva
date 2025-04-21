import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person_model.dart';

class PersonService {
  final String baseUrl = 'http://192.168.0.15:5205/Person';

  Future<List<PersonType>> getPersons() async {
    final response = await http.get(Uri.parse(baseUrl));
    print('BODY: ${response.body}');
    print('STATUS: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['resultList'];
      return data.map((item) => PersonType.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load persons');
    }
  }
}
