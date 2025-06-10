import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel_model.dart';
import '../services/auth_service.dart';

class ParcelService {
  static const String baseUrl = "http://localhost:5205";

  static Future<List<Parcel>> fetchAll({
    DateTime? from,
    DateTime? to,
    bool? shade,
    bool? electricity,
    String? accommodation,
    String? type,
    int page = 0,
    int pageSize = 10,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final uri = Uri.parse('$baseUrl/Parcel').replace(
      queryParameters: {
        if (shade != null) 'Shade': shade.toString(),
        if (electricity != null) 'Electricity': electricity.toString(),
        if (accommodation != null && accommodation.isNotEmpty)
          'ParcelAccommodationName': accommodation,
        if (type != null && type.isNotEmpty) 'ParcelTypeName': type,
        if (from != null) 'DateFrom': from.toIso8601String(),
        if (to != null) 'DateTo': to.toIso8601String(),
        'IsParcelAccommodationIncluded': 'true',
        'IsParcelTypeIncluded': 'true',
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
      },
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final rawItems = jsonData['resultList'];

      return (rawItems is List
              ? rawItems.whereType<Map<String, dynamic>>()
              : <Map<String, dynamic>>[])
          .map((e) => Parcel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load parcels');
    }
  }

  static Future<void> create(Parcel data) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/Parcel'),
      headers: headers,
      body: json.encode(data.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create parcel');
    }
  }

  static Future<void> update(Parcel parcel) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/Parcel/${parcel.id}');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(parcel.toUpdateJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update parcel');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/Parcel/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete parcel');
    }
  }

  static Future<List<int>> fetchUnavailableParcelIds(
    DateTime from,
    DateTime to,
  ) async {
    final headers = await AuthService.getAuthHeaders();
    final uri = Uri.parse('$baseUrl/Parcel/unavailable').replace(
      queryParameters: {
        'DateFrom': from.toIso8601String(),
        'DateTo': to.toIso8601String(),
      },
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<int>((item) => item['parcelId'] as int).toList();
    } else {
      throw Exception('Failed to fetch unavailable parcels');
    }
  }
}
