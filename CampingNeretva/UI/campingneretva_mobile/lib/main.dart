import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:campingneretva_mobile/screens/home_page.dart';
import 'package:campingneretva_mobile/screens/profile_page.dart';
import 'package:campingneretva_mobile/screens/facilities_page.dart';
import 'package:campingneretva_mobile/screens/parcels_page.dart';
import 'package:campingneretva_mobile/screens/activities_rentables_page.dart';
import 'package:campingneretva_mobile/screens/login_page.dart';
import 'package:campingneretva_mobile/screens/register_page.dart';
import 'package:campingneretva_mobile/screens/review_page.dart';
import 'package:campingneretva_mobile/screens/reservation_page.dart';
import 'package:campingneretva_mobile/screens/reservation_history_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camping Neretva',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/facilities': (context) => const FacilitiesPage(),
        '/parcels': (context) => const ParcelsPage(),
        '/activities-rentables': (_) => const ActivitiesRentablesPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/review': (context) => const ReviewPage(),
        '/reservation': (context) => const ReservationPage(),
        '/reservation-history': (context) => const ReservationHistoryPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
