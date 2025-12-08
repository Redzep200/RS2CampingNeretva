import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_comment_notification_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActivityAnalysisService {
  static final String _baseUrl = dotenv.env['API_URL']!;

  static Future<List<CommentAnalysisResult>> getNotifications() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final url = Uri.parse('$_baseUrl/ActivityAnalysis/notifications');

      print('🔍 Fetching notifications from: $url');
      print('📝 Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => CommentAnalysisResult.fromJson(e)).toList();
      } else {
        throw Exception(
          'Failed to load notifications. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getNotifications: $e');
      rethrow;
    }
  }

  static Future<int> getNotificationCount() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final url = Uri.parse('$_baseUrl/ActivityAnalysis/notifications/count');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] as int;
      } else {
        throw Exception('Failed to load notification count');
      }
    } catch (e) {
      print('❌ Error in getNotificationCount: $e');
      rethrow;
    }
  }

  static Future<void> triggerAnalysis() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final url = Uri.parse('$_baseUrl/ActivityAnalysis/analyze');

      print('🔍 Triggering analysis at: $url');

      final response = await http.post(url, headers: headers);

      print('📊 Analysis response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to trigger analysis. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error in triggerAnalysis: $e');
      rethrow;
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final url = Uri.parse(
        '$_baseUrl/ActivityAnalysis/notifications/$notificationId/mark-read',
      );

      print('🔍 Marking notification as read: $url');
      print('📝 Request headers: $headers');
      print('🆔 Notification ID: $notificationId');

      final response = await http.put(url, headers: headers);

      print('📊 Mark as read response status: ${response.statusCode}');
      print('📄 Mark as read response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Successfully marked notification $notificationId as read');
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Notification not found (ID: $notificationId)');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please check your authentication');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Forbidden - you do not have permission to mark this notification as read',
        );
      } else {
        throw Exception(
          'Failed to mark as read. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in markAsRead: $e');
      rethrow;
    }
  }
}
