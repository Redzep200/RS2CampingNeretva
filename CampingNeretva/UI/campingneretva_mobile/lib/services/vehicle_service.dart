import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VehicleService {
  static String get baseUrl => '${dotenv.env['API_URL']!}/Vehicle';

  static Future<List<Vehicle>> getVehicles() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['resultList'];
      return data.map((item) => Vehicle.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }
}
