import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campingneretva_mobile/models/activity_model.dart';
import '../services/auth_service.dart';

class ActivityService {
  static const String baseUrl = "http://10.0.2.2:5205";

  static Future<List<Activity>> getByDateRange(String? from, String? to) async {
    Uri uri;

    if (from != null && to != null) {
      uri = Uri.parse("$baseUrl/Activity?DateFrom=$from&DateTo=$to");
    } else {
      uri = Uri.parse("$baseUrl/Activity");
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['resultList'];
      return data.map((e) => Activity.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load activities: ${response.statusCode}");
    }
  }

  static Future<List<Activity>> getRecommendedActivities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/UserPreference/recommended/activities'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Activity.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load recommended activities");
    }
  }
}
