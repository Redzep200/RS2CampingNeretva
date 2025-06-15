import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReviewService {
  static final String baseUrl = dotenv.env['API_URL']!;

  static Future<List<Review>> getAll({int? workerId, int? userId}) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final queryParameters = {
        if (workerId != null) 'WorkerId': '$workerId',
        if (userId != null) 'UserId': '$userId',
        'IsUserIncluded': 'true',
        'IsWorkerIncluded': 'true',
      };

      final uri = Uri.parse(
        '$baseUrl/Review',
      ).replace(queryParameters: queryParameters);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List results = body['resultList'] ?? [];
        print('Fetched ${results.length} reviews');
        return results.map((e) => Review.fromJson(e)).toList();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('GetAll Error: $e');
      rethrow;
    }
  }

  Future<List<Review>> getByWorkerId(int workerId) async {
    final headers = await AuthService.getAuthHeaders();
    final queryParams = {
      'WorkerId': '$workerId',
      'IsUserIncluded': 'true',
      'IsWorkerIncluded': 'true',
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await http.get(
      Uri.parse('$baseUrl/Review?$queryString'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List results = body['resultList'];
      return results
          .where((e) => e != null)
          .map((e) => Review.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load reviews for worker $workerId');
    }
  }
}
