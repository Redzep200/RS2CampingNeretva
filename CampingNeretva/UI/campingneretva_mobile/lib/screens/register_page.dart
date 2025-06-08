import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _numberOfPeople = TextEditingController();
  bool _hasSmallChildren = false;
  bool _hasSeniorTravelers = false;
  String? _carLength;
  bool _hasDogs = false;

  String? error;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final user = await AuthService.register(
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phoneNumber: _phoneNumber.text.trim(),
        passwordConfirmation: _confirmPassword.text.trim(),
      );

      if (user != null) {
        // Save user preferences
        await http.post(
          Uri.parse('http://10.0.2.2:5205/UserPreference'),
          headers: await AuthService.getAuthHeaders(),
          body: jsonEncode({
            'numberOfPeople': int.parse(_numberOfPeople.text),
            'hasSmallChildren': _hasSmallChildren,
            'hasSeniorTravelers': _hasSeniorTravelers,
            'carLength': _carLength,
            'hasDogs': _hasDogs,
          }),
        );
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => error = "Registration failed. Try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v!.isEmpty ? 'Username required' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email required';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return emailRegex.hasMatch(v) ? null : 'Enter a valid email';
                },
              ),
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'First name required';
                  final nameRegex = RegExp(r'^[a-zA-Z]+$');
                  return nameRegex.hasMatch(v) ? null : 'Only letters allowed';
                },
              ),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Last name required';
                  final nameRegex = RegExp(r'^[a-zA-Z]+$');
                  return nameRegex.hasMatch(v) ? null : 'Only letters allowed';
                },
              ),
              TextFormField(
                controller: _phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Phone number required';
                  final phoneRegex = RegExp(r'^\d+$');
                  return phoneRegex.hasMatch(v) ? null : 'Only digits allowed';
                },
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (v) =>
                        v!.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
              ),
              TextFormField(
                controller: _confirmPassword,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator:
                    (v) =>
                        v != _password.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                "Tell us about yourself",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _numberOfPeople,
                decoration: const InputDecoration(
                  labelText: 'Number of People',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              CheckboxListTile(
                title: const Text("Traveling with small children"),
                value: _hasSmallChildren,
                onChanged: (v) => setState(() => _hasSmallChildren = v!),
              ),
              CheckboxListTile(
                title: const Text("Traveling with senior travelers"),
                value: _hasSeniorTravelers,
                onChanged: (v) => setState(() => _hasSeniorTravelers = v!),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Car Length'),
                value: _carLength,
                items:
                    ['Small', 'Medium', 'Large']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) => setState(() => _carLength = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              CheckboxListTile(
                title: const Text("Traveling with dogs"),
                value: _hasDogs,
                onChanged: (v) => setState(() => _hasDogs = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
