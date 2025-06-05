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
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser!;
    _username = TextEditingController(text: user.username);
    _email = TextEditingController(text: user.email);
    _phone = TextEditingController(text: user.phoneNumber ?? '');
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
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

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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
