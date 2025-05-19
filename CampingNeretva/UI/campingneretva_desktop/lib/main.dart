import 'package:campingneretva_desktop/screens/facility_page.dart';
import 'package:campingneretva_desktop/screens/prices_page.dart';
import 'package:flutter/material.dart';
import 'package:campingneretva_desktop/screens/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  runApp(AdminDesktopApp());
}

class AdminDesktopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/prices': (context) => const PricePage(),
        '/facilities': (context) => const FacilityPage(),
      },
    );
  }
}
