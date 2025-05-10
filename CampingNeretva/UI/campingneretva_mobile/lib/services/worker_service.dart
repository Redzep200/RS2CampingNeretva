import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/worker_model.dart';

class WorkerService {
  static const String baseUrl = "http://192.168.0.15:5205";

  static Future<List<Worker>> getAll() async {
    final response = await http.get(Uri.parse('$baseUrl/Worker'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List results = body['resultList'];
      return results.map((e) => Worker.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load workers');
    }
  }
}
