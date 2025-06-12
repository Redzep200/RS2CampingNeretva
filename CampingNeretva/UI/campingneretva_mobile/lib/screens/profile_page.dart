import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _username;
  late TextEditingController _email;
  late TextEditingController _phone;
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _numberOfPeople = TextEditingController();
  bool _hasSmallChildren = false;
  bool _hasSeniorTravelers = false;
  String? _carLength;
  bool _hasDogs = false;
  bool _isEditing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser!;
    _username = TextEditingController(text: user.username);
    _email = TextEditingController(text: user.email);
    _phone = TextEditingController(text: user.phoneNumber ?? '');
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5205/UserPreference'),
        headers: await AuthService.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _numberOfPeople.text = (data['numberOfPeople'] ?? 0).toString();
          _hasSmallChildren = data['hasSmallChildren'] ?? false;
          _hasSeniorTravelers = data['hasSeniorTravelers'] ?? false;
          _carLength = data['carLength'] ?? null;
          _hasDogs = data['hasDogs'] ?? false;
        });
      } else if (response.statusCode == 404) {
        // No preferences found, set defaults
        setState(() {
          _numberOfPeople.text = '0';
          _hasSmallChildren = false;
          _hasSeniorTravelers = false;
          _carLength = null;
          _hasDogs = false;
        });
      } else {
        print(
          'Failed to load preferences: ${response.statusCode} - ${response.body}',
        );
        setState(() => _error = 'Failed to load preferences');
      }
    } catch (e) {
      print('Error loading preferences: $e');
      setState(() => _error = 'Error loading preferences');
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updated = await UserService().updateOwnProfile(
          username: _username.text,
          email: _email.text,
          phoneNumber: _phone.text,
          password: _password.text.isNotEmpty ? _password.text : null,
          passwordConfirmation:
              _confirmPassword.text.isNotEmpty ? _confirmPassword.text : null,
        );

        if (updated != null) {
          final prefResponse = await http.put(
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
          if (prefResponse.statusCode == 200) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Profile updated")));
            _toggleEdit();
            setState(() => _error = null);
          } else {
            throw Exception('Failed to save preferences');
          }
        } else {
          throw Exception('Update failed');
        }
      } catch (e) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      _error = null;
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _numberOfPeople.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = !_isEditing;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: "Username"),
                readOnly: readOnly,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: "Email"),
                readOnly: readOnly,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return emailRegex.hasMatch(v) ? null : 'Invalid email';
                },
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: "Phone"),
                readOnly: readOnly,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Phone number required';
                  final phoneRegex = RegExp(r'^\+?[\d\s-]{8,}$');
                  return phoneRegex.hasMatch(v)
                      ? null
                      : 'Enter a valid phone number (min 8 digits)';
                },
              ),
              if (_isEditing) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: "New Password"),
                  obscureText: true,
                  validator:
                      (v) =>
                          v!.isNotEmpty && v.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                ),
                TextFormField(
                  controller: _confirmPassword,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                  ),
                  obscureText: true,
                  validator:
                      (v) =>
                          v != _password.text && v!.isNotEmpty
                              ? 'Passwords do not match'
                              : null,
                ),
              ],
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
                readOnly: readOnly,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              CheckboxListTile(
                title: const Text("Traveling with small children"),
                value: _hasSmallChildren,
                onChanged:
                    readOnly
                        ? null
                        : (v) => setState(() => _hasSmallChildren = v!),
              ),
              CheckboxListTile(
                title: const Text("Traveling with senior travelers"),
                value: _hasSeniorTravelers,
                onChanged:
                    readOnly
                        ? null
                        : (v) => setState(() => _hasSeniorTravelers = v!),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Car Length'),
                value: _carLength,
                items:
                    ['Small', 'Medium', 'Large']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged:
                    readOnly ? null : (v) => setState(() => _carLength = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              CheckboxListTile(
                title: const Text("Traveling with dogs"),
                value: _hasDogs,
                onChanged:
                    readOnly ? null : (v) => setState(() => _hasDogs = v!),
              ),
              const SizedBox(height: 20),
              if (_isEditing)
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Save Changes"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
