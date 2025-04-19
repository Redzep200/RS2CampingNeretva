import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/acommodation_model.dart';

class AccommodationService {
  final String baseUrl = 'http://10.0.2.2:5205/Accommodation';

  Future<List<Accommodation>> getAccommodations() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['resultList'];
      return data.map((item) => Accommodation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load accommodations');
    }
  }
}
