import 'dart:convert';
import 'package:http/http.dart' as http;
import './auth_service.dart';
import '../models/activity_comment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActivityCommentService {
  static final String _baseUrl = dotenv.env['API_URL']!;

  static Future<List<ActivityComment>> getByActivityId(int activityId) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final uri = Uri.parse(
        '$_baseUrl/ActivityComments',
      ).replace(queryParameters: {'ActivityId': activityId.toString()});

      print('Fetching reviews from: $uri');

      final response = await http.get(uri, headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List data = body['resultList'];
        return data.map((e) => ActivityComment.fromJson(e)).toList();
      } else {
        throw Exception(
          'Failed to load Activity Comments: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getByActivityId: $e');
      rethrow;
    }
  }

  static Future<void> insert(ActivityComment comment) async {
    final headers = await AuthService.getAuthHeaders();

    final uri = Uri.parse('$_baseUrl/ActivityComments');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(comment.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit comment');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();

    final uri = Uri.parse('$_baseUrl/ActivityComments/$id');

    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }
}
