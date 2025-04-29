import 'package:flutter/material.dart';
import 'package:campingneretva_mobile/screens/home_page.dart';
import 'package:campingneretva_mobile/screens/facilities_page.dart';
import 'package:campingneretva_mobile/screens/parcels_page.dart';

void main() {
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
      },
    );
  }
}
