import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/acommodation_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccommodationService {
  static String get baseUrl => '${dotenv.env['API_URL']!}/Accommodation';

  static Future<List<Accommodation>> getAccommodations() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['resultList'];
      return data.map((item) => Accommodation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load accommodations');
    }
  }
}
