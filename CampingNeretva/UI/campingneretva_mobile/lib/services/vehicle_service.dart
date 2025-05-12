import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_model.dart';

class VehicleService {
  static String baseUrl = 'http://192.168.0.15:5205/Vehicle';

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
