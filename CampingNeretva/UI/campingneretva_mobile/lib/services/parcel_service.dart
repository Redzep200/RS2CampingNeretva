import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parcel.dart';

class ParcelService {
  static const String baseUrl =
      'https://172.27.80.1:7287/Parcel'; // ← change to your backend IP/port

  static Future<List<Parcel>> fetchParcels() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['resultList'];

      return list.map((e) => Parcel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load parcels');
    }
  }
}
