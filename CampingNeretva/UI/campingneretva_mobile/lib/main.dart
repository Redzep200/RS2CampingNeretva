import 'package:flutter/material.dart';
import 'screens/parcel_list_screen.dart';

void main() {
  print('🔥 THIS IS THE REAL APP');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camping Neretva',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const ParcelListScreen(),
    );
  }
}
