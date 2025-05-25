import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campingneretva_desktop/models/rentable_item_model.dart';
import '../services/auth_service.dart';

class RentableItemService {
  static const String _baseUrl = "http://localhost:5205";

  static Future<List<RentableItem>> getAvailable(
    String? from,
    String? to,
  ) async {
    Uri uri;

    if (from != null && to != null) {
      uri = Uri.parse("$_baseUrl/RentableItem/available?from=$from&to=$to");
    } else {
      uri = Uri.parse("$_baseUrl/RentableItem/available");
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      print('Parsed ${data.length} items from response');

      final items = data.map((e) => RentableItem.fromJson(e)).toList();

      return items;
    } else {
      throw Exception(
        "Failed to load rentable items: ${response.statusCode} - ${response.body}",
      );
    }
  }

  static Future<List<RentableItem>> fetchAll() async {
    final res = await http.get(Uri.parse('$_baseUrl/RentableItem'));

    final responseData = json.decode(res.body);
    final jsonList = responseData['resultList'];
    return List<RentableItem>.from(
      jsonList.map((x) => RentableItem.fromJson(x)),
    );
  }

  static Future<void> create(RentableItem item) async {
    final headers = await AuthService.getAuthHeaders();
    await http.post(
      Uri.parse('$_baseUrl/RentableItem'),
      headers: headers,
      body: json.encode(item.toJson()),
    );
  }

  static Future<void> update(RentableItem item) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/RentableItem/${item.id}');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(item.toUpdateJson()),
    );

    if (response.statusCode != 200) {
      print('Update failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update item');
    }
  }

  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final url = Uri.parse('$_baseUrl/RentableItem/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }
}
