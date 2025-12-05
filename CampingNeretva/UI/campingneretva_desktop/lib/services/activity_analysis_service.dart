import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_comment_notification_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActivityAnalysisService {
  static final String _baseUrl = dotenv.env['API_URL']!;

  static Future<List<CommentAnalysisResult>> getNotifications() async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/ActivityAnalysis/notifications');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CommentAnalysisResult.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  static Future<void> triggerAnalysis() async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/ActivityAnalysis/analyze');

    final response = await http.post(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to trigger analysis');
    }
  }

  static Future<void> markAsReviewed(int notificationId) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse(
      '$_baseUrl/ActivityAnalysis/notifications/$notificationId/review',
    );

    final response = await http.put(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to mark as reviewed');
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.put(
      Uri.parse(
        '$_baseUrl/ActivityAnalysis/notifications/$notificationId/mark-read',
      ),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception('Failed to mark as read');
  }
}
