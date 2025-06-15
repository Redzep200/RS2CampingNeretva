import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/worker_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WorkerService {
  static String get baseUrl => dotenv.env['API_URL']!;

  static Future<List<Worker>> getAll() async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/Worker'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List results = body['resultList'];
      return results.map((e) => Worker.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load workers');
    }
  }
}
