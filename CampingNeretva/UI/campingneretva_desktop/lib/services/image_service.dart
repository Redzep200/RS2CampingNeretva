import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/image_model.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';

class ImageService {
  static const String _baseUrl = 'http://localhost:5205';

  // Fetch all images
  static Future<List<ImageModel>> fetchAll() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/images'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['resultList'];
      return List<ImageModel>.from(data.map((e) => ImageModel.fromJson(e)));
    } else {
      throw Exception('Failed to load images');
    }
  }

  // Upload a new image (using multipart form data)
  static Future<ImageModel> upload(File imageFile) async {
    final headers = await AuthService.getAuthHeaders();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/Image/upload'),
    );
    request.headers.addAll(headers);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Upload failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to upload image');
    }

    final jsonResponse = json.decode(response.body);
    return ImageModel.fromJson(jsonResponse);
  }

  // Delete image by ID
  static Future<void> delete(int id) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/Image/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete image');
    }
  }
}
