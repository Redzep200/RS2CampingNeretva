import 'package:campingneretva_desktop/screens/prices_page.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:campingneretva_desktop/models/user_model.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final user = await AuthService.login(username, password);
      if (user!.userType.typeName != 'Admin') {
        _showError('Only admin users can access this application.');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PricePage()),
      );
    } catch (e) {
      _showError('Login failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Access Denied'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin Login',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(onPressed: _login, child: Text('Login')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
