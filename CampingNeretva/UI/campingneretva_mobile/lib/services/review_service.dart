import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../services/auth_service.dart';

class ReviewService {
  static const String baseUrl = "http://10.0.2.2:5205";

  static Future<List<Review>> getAll({
    int? workerId,
    int? userId,
    int page = 0,
    int pageSize = 4,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    try {
      final queryParameters = {
        if (workerId != null) 'WorkerId': '$workerId',
        if (userId != null) 'UserId': '$userId',
        'IsUserIncluded': 'true',
        'IsWorkerIncluded': 'true',
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'OrderBy': 'DatePosted desc',
      };

      final uri = Uri.parse(
        '$baseUrl/Review',
      ).replace(queryParameters: queryParameters);
      print('Request URL: $uri');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final bodyRaw = response.body;
        final body = json.decode(bodyRaw);
        print('GetAll response: $body');

        if (body is Map && body.containsKey('resultList')) {
          final List results = body['resultList'];
          return results.map((e) => Review.fromJson(e)).toList();
        } else {
          print('Unexpected body format: $body');
          return [];
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('GetAll Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    if (AuthService.currentUser == null) {
      throw Exception('User not logged in');
    }

    final username = AuthService.currentUser!.username;
    final password = "password";

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {'Content-Type': 'application/json', 'Authorization': basicAuth};
  }

  static Future<void> submit({
    required int userId,
    required int workerId,
    required int rating,
    required String comment,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/Review'),
        headers: headers,
        body: json.encode({
          'userId': userId,
          'workerId': workerId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      print('Submit Error: $e');
      rethrow;
    }
  }

  static Future<void> update({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/Review/$reviewId'),
        headers: headers,
        body: json.encode({
          'reviewId': reviewId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update review: ${response.statusCode}');
      }
    } catch (e) {
      print('Update Error: $e');
      rethrow;
    }
  }
}
