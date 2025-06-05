import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static User? currentUser;
  static String? _password;
  static const storage = FlutterSecureStorage();
  static const String baseUrl = 'http://10.0.2.2:5205';

  // Login method
  static Future<User?> login(String username, String password) async {
    try {
      // Create basic auth header
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

        // Store credentials securely
        await storage.write(key: 'username', value: username);
        await storage.write(key: 'password', value: password);
        _password = password; // Keep in memory for current session

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

  // Register method
  static Future<User?> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/User'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'passwordConfirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Auto-login after successful registration
        return await login(username, password);
      } else {
        print('Registration failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Get auth headers for API calls
  static Future<Map<String, String>> getAuthHeaders() async {
    if (currentUser == null) {
      final username = await storage.read(key: 'username');
      final password = await storage.read(key: 'password');

      if (username != null && password != null) {
        await login(username, password);
      } else {
        throw Exception('Not logged in');
      }
    }

    // Use stored password or get it from secure storage
    String? password = _password;
    if (password == null) {
      password = await storage.read(key: 'password');
      if (password == null) throw Exception('Not logged in');
    }

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('${currentUser!.username}:$password'))}';

    return {'Content-Type': 'application/json', 'Authorization': basicAuth};
  }

  // Try to restore session from secure storage
  static Future<bool> tryRestoreSession() async {
    try {
      final username = await storage.read(key: 'username');
      final password = await storage.read(key: 'password');

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

  // Logout
  static Future<void> logout() async {
    currentUser = null;
    _password = null;
    await storage.deleteAll();
  }

  // Check if logged in
  static bool isLoggedIn() => currentUser != null;
}
