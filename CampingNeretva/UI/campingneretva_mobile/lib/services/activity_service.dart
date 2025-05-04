import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campingneretva_mobile/models/activity_model.dart';

class ActivityService {
  static const String baseUrl = "http://192.168.0.15:5205";

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
}
