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
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5205/UserPreference'),
      headers: await AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _numberOfPeople.text = data['numberOfPeople'].toString();
        _hasSmallChildren = data['hasSmallChildren'];
        _hasSeniorTravelers = data['hasSeniorTravelers'];
        _carLength = data['carLength'];
        _hasDogs = data['hasDogs'];
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final updated = await UserService().updateOwnProfile(
        username: _username.text,
        email: _email.text,
        phoneNumber: _phone.text,
        password: _password.text,
        passwordConfirmation: _confirmPassword.text,
      );

      if (updated != null) {
        await http.put(
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile updated")));
        _toggleEdit();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Update failed")));
      }
    }
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
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
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: "Username"),
                readOnly: readOnly,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: "Email"),
                readOnly: readOnly,
                validator:
                    (value) => value!.contains('@') ? null : 'Invalid email',
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: "Phone"),
                readOnly: readOnly,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: "New Password"),
                  obscureText: true,
                ),
                TextFormField(
                  controller: _confirmPassword,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                  ),
                  obscureText: true,
                  validator:
                      (value) =>
                          value != _password.text
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
