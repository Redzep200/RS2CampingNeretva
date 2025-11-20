import 'dart:convert';
import 'package:http/http.dart' as http;
import './auth_service.dart';
import '../models/activity_comment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActivityCommentService {
  static final String _baseUrl = dotenv.env['API_URL']!;

  static Future<List<ActivityComment>> getByActivityId(int activityId) async {
    final headers = await AuthService.getAuthHeaders();

    final uri = Uri.parse(
      '$_baseUrl/ActivityComment',
    ).replace(queryParameters: {'ActivityId': activityId.toString()});

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['resultList'];
      return data.map((e) => ActivityComment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Activity Comments');
    }
  }

  // static Future<void> insert(ActivityComment comment) async {
  //   final headers = await AuthService.getAuthHeaders();

  //   final uri = Uri.parse('$_baseUrl/ActivityComment');

  //   final response = await http.post(
  //     uri,
  //     headers: headers,
  //     body: jsonEncode(comment.toJson()),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to submit comment');
  //   }
  // }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();

    final uri = Uri.parse('$_baseUrl/ActivityComment/$id');

    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }

  static Future<bool> addComment({
    required int activityId,
    required int userId,
    required String commentText,
    required int rating,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final url = Uri.parse("$_baseUrl/ActivityComments");

      final body = jsonEncode({
        "activityId": activityId,
        "userId": userId,
        "commentText": commentText,
        "rating": rating,
      });

      final response = await http.post(url, headers: headers, body: body);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }
}
