import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/user_type_service.dart';

class NewAdminDialog extends StatefulWidget {
  final VoidCallback onUserCreated;

  const NewAdminDialog({Key? key, required this.onUserCreated})
    : super(key: key);

  @override
  State<NewAdminDialog> createState() => _NewAdminDialogState();
}

class _NewAdminDialogState extends State<NewAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _error = null);

    try {
      final userTypes = await UserTypeService().getUserTypes();
      final adminType = userTypes.firstWhere((x) => x.typeName == "Admin");

      await UserService().insertUser({
        'firstName': _firstName.text,
        'lastName': _lastName.text,
        'userName': _username.text,
        'email': _email.text,
        'password': _password.text,
        'passwordConfirmation': _confirmPassword.text,
        'userTypeId': adminType.id,
      });

      widget.onUserCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kreiraj novog admina'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(labelText: 'Ime'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obavezno polje';
                  if (RegExp(r'\d').hasMatch(value))
                    return 'Ime ne smije sadržavati brojeve';
                  return null;
                },
              ),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(labelText: 'Prezime'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obavezno polje';
                  if (RegExp(r'\d').hasMatch(value))
                    return 'Prezime ne smije sadržavati brojeve';
                  return null;
                },
              ),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Korisničko ime'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Obavezno polje'
                            : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obavezno polje';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                    return 'Neispravan email';
                  return null;
                },
              ),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Lozinka'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Obavezno polje'
                            : null,
              ),
              TextFormField(
                controller: _confirmPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Potvrdi lozinku'),
                validator:
                    (value) =>
                        value != _password.text
                            ? 'Lozinke se ne podudaraju'
                            : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Otkaži'),
        ),
        ElevatedButton(onPressed: _createAdmin, child: const Text('Spremi')),
      ],
    );
  }
}
