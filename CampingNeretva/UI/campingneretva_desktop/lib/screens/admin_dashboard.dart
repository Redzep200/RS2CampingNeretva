import 'package:flutter/material.dart';
import 'package:campingneretva_desktop/models/user_model.dart';
import 'package:campingneretva_desktop/widgets/navbar.dart'; // Make sure this is the correct path

class AdminDashboard extends StatelessWidget {
  final User user;

  const AdminDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(), // Use your custom green navbar here
      body: Center(
        child: Text('Welcome, ${user.firstName} (${user.userType.typeName})'),
      ),
    );
  }
}
