import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campingneretva_desktop/models/user_model.dart';
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static User? currentUser;
  static String? _password;
  static final Box _box = Hive.box('authBox');
  static final String baseUrl = dotenv.env['API_URL']!;

  static Future<User?> login(String username, String password) async {
    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final response = await http.post(
        Uri.parse('$baseUrl/User/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        currentUser = User.fromJson(jsonDecode(response.body));

        // Store credentials
        await _box.put('username', username);
        await _box.put('password', password);
        _password = password;

        return currentUser;
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    if (currentUser == null) {
      final username = _box.get('username');
      final password = _box.get('password');

      if (username != null && password != null) {
        await login(username, password);
      } else {
        throw Exception('Not logged in');
      }
    }

    String? password = _password ?? _box.get('password');
    if (password == null) throw Exception('Not logged in');

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('${currentUser!.username}:$password'))}';

    return {'Content-Type': 'application/json', 'Authorization': basicAuth};
  }

  static Future<bool> tryRestoreSession() async {
    try {
      final username = _box.get('username');
      final password = _box.get('password');

      if (username != null && password != null) {
        final user = await login(username, password);
        return user != null;
      }
      return false;
    } catch (e) {
      print('Restore session error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    currentUser = null;
    _password = null;
    await _box.delete('username');
    await _box.delete('password');
  }

  static bool isLoggedIn() => currentUser != null;
}
