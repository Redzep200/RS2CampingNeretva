import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel_model.dart';
import '../services/auth_service.dart';

class ParcelService {
  static const String baseUrl = "http://10.0.2.2:5205";

  static Future<List<Parcel>> getParcels({
    DateTime? from,
    DateTime? to,
    bool? shade,
    bool? electricity,
    String? accommodation,
    String? type,
  }) async {
    final uri = Uri.parse('$baseUrl/Parcel').replace(
      queryParameters: {
        if (from != null) 'dateFrom': from.toIso8601String(),
        if (to != null) 'dateTo': to.toIso8601String(),
        if (shade != null) 'shade': shade.toString(),
        if (electricity != null) 'electricity': electricity.toString(),
        if (accommodation != null && accommodation.isNotEmpty)
          'parcelAccommodationName': accommodation,
        if (type != null && type.isNotEmpty) 'parcelTypeName': type,
        'isParcelAccommodationIncluded': 'true',
        'isParcelTypeIncluded': 'true',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List items = jsonData['resultList'];
      return items.map((e) => Parcel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load parcels');
    }
  }

  static Future<List<Parcel>> getRecommendedParcels() async {
    final response = await http.get(
      Uri.parse('$baseUrl/UserPreference/recommended/parcels'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List items = jsonDecode(response.body);
      return items.map((e) => Parcel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load recommended parcels');
    }
  }
}
