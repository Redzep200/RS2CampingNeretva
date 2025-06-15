import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/worker_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WorkerService {
  static final String _baseUrl = dotenv.env['API_URL']!;

  static Future<List<Worker>> fetchAll() async {
    final res = await http.get(Uri.parse('$_baseUrl/Worker'));
    final jsonList = json.decode(res.body)['resultList'];
    return List<Worker>.from(jsonList.map((x) => Worker.fromJson(x)));
  }

  static Future<void> create(Map<String, dynamic> data) async {
    final headers = await AuthService.getAuthHeaders();
    await http.post(
      Uri.parse('$_baseUrl/Worker'),
      headers: headers,
      body: json.encode(data),
    );
  }

  static Future<void> update(Worker worker) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Worker/${worker.id}');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(worker.toUpdateJson()),
    );

    if (response.statusCode != 200) {
      print('Update failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update worker');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Worker/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete worker');
    }
  }

  Future<List<Worker>> getAllPaginated({
    int page = 0,
    int pageSize = 100,
    bool includeRoles = false,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final queryParams = {
      'Page': '$page',
      'PageSize': '$pageSize',
      if (includeRoles) 'IsWorkerRoleIncluded': 'true',
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await http.get(
      Uri.parse('$_baseUrl/Worker?$queryString'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List results = body['resultList'];
      return results.map((e) => Worker.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load workers');
    }
  }
}
