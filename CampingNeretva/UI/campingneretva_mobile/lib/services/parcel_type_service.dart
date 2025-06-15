import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel_type_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParcelTypeService {
  static String get baseUrl => dotenv.env['API_URL']!;

  Future<List<ParcelType>> getParcelTypes() async {
    final response = await http.get(Uri.parse('$baseUrl/ParcelType'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List items = jsonData['resultList'];
      return items.map((e) => ParcelType.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load parcel types');
    }
  }
}
