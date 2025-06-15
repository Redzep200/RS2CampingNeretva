import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static User? currentUser;
  static String? _password;
  static const storage = FlutterSecureStorage();
  static String get baseUrl => dotenv.env['API_URL']!;

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

        await storage.write(key: 'username', value: username);
        await storage.write(key: 'password', value: password);
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
        return await login(username, password);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message']?.toString() ?? 'Registration failed';
        if (errorMessage.contains('Username is already taken')) {
          throw Exception('Username already in use');
        } else if (errorMessage.contains('Email is already in use')) {
          throw Exception('Email already in use');
        } else {
          print(
            'Registration failed: ${response.statusCode} - ${response.body}',
          );
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

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

    String? password = _password;
    if (password == null) {
      password = await storage.read(key: 'password');
      if (password == null) throw Exception('Not logged in');
    }

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('${currentUser!.username}:$password'))}';

    return {'Content-Type': 'application/json', 'Authorization': basicAuth};
  }

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

  static Future<void> logout() async {
    currentUser = null;
    _password = null;
    await storage.deleteAll();
  }

  static bool isLoggedIn() => currentUser != null;
}
