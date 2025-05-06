import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  static User? currentUser;

  static Future<User?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.15:5205/User/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      currentUser = User.fromJson(jsonDecode(response.body));
      return currentUser;
    } else {
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
    final response = await http.post(
      Uri.parse('http://192.168.0.15:5205/User'),
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
      return User.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  static void logout() {
    currentUser = null;
  }

  static bool isLoggedIn() => currentUser != null;
}
