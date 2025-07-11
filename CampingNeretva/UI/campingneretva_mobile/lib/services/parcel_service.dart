import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParcelService {
  static String get baseUrl => dotenv.env['API_URL']!;

  static Future<List<Parcel>> getParcels({
    DateTime? from,
    DateTime? to,
    bool? shade,
    bool? electricity,
    String? accommodation,
    String? type,
    int page = 0,
    int pageSize = 6,
  }) async {
    final queryParameters = {
      if (from != null) 'dateFrom': from.toIso8601String(),
      if (to != null) 'dateTo': to.toIso8601String(),
      if (shade != null) 'shade': shade.toString(),
      if (electricity != null) 'electricity': electricity.toString(),
      if (accommodation != null && accommodation.isNotEmpty)
        'parcelAccommodationName': accommodation,
      if (type != null && type.isNotEmpty) 'parcelTypeName': type,
      'isParcelAccommodationIncluded': 'true',
      'isParcelTypeIncluded': 'true',
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      'OrderBy': 'ParcelNumber asc',
    };

    final uri = Uri.parse(
      '$baseUrl/Parcel',
    ).replace(queryParameters: queryParameters);
    print('Request URL: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('GetParcels response: $jsonData');
      final List items = jsonData['resultList'] ?? [];
      return items.map((e) => Parcel.fromJson(e)).toList();
    } else {
      print('GetParcels failed: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load parcels: ${response.body}');
    }
  }

  static Future<List<Parcel>> getRecommendedParcels() async {
    final response = await http.get(
      Uri.parse('$baseUrl/UserPreference/recommended/parcels'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List items = jsonDecode(response.body);
      print('GetRecommendedParcels response: $items');
      return items.map((e) => Parcel.fromJson(e)).toList();
    } else {
      print(
        'GetRecommendedParcels failed: ${response.statusCode} ${response.body}',
      );
      throw Exception('Failed to load recommended parcels: ${response.body}');
    }
  }

  static Future<List<Parcel>> getAllParcels({
    DateTime? from,
    DateTime? to,
    bool? shade,
    bool? electricity,
    String? accommodation,
    String? type,
  }) async {
    final queryParameters = {
      if (from != null) 'dateFrom': from.toIso8601String(),
      if (to != null) 'dateTo': to.toIso8601String(),
      if (shade != null) 'shade': shade.toString(),
      if (electricity != null) 'electricity': electricity.toString(),
      if (accommodation != null && accommodation.isNotEmpty)
        'parcelAccommodationName': accommodation,
      if (type != null && type.isNotEmpty) 'parcelTypeName': type,
      'isParcelAccommodationIncluded': 'true',
      'isParcelTypeIncluded': 'true',
      'OrderBy': 'ParcelNumber asc',
    };

    final uri = Uri.parse(
      '$baseUrl/Parcel',
    ).replace(queryParameters: queryParameters);
    print('Request URL: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('GetParcels response: $jsonData');
      final List items = jsonData['resultList'] ?? [];
      return items.map((e) => Parcel.fromJson(e)).toList();
    } else {
      print('GetParcels failed: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load parcels: ${response.body}');
    }
  }
}
