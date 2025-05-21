import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';

class ActivityService {
  static const String _baseUrl = 'http://localhost:5205';

  static Future<List<Activity>> fetchAll() async {
    final res = await http.get(Uri.parse('$_baseUrl/Activity'));
    final jsonList = json.decode(res.body)['resultList'];
    return List<Activity>.from(jsonList.map((x) => Activity.fromJson(x)));
  }

  static Future<void> create(Activity item) async {
    final headers = await AuthService.getAuthHeaders();
    await http.post(
      Uri.parse('$_baseUrl/Activity'),
      headers: headers,
      body: json.encode(item.toJson()),
    );
  }

  static Future<void> update(Activity activity) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Activity/${activity.id}');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(activity.toUpdateJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update activity');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/Activity/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete activity');
    }
  }
}
