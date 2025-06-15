import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/facility_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FacilityService {
  static String get baseUrl => dotenv.env['API_URL']!;

  Future<List<Facility>> getFacilities() async {
    final response = await http.get(Uri.parse('$baseUrl/Facility'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List results = body['resultList'];
      return results.map((e) => Facility.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load facilities');
    }
  }
}
