import 'package:campingneretva_desktop/screens/activity_page.dart';
import 'package:campingneretva_desktop/screens/facility_page.dart';
import 'package:campingneretva_desktop/screens/prices_page.dart';
import 'package:campingneretva_desktop/screens/rentable_item_page.dart';
import 'package:campingneretva_desktop/screens/reservations_page.dart';
import 'package:campingneretva_desktop/screens/users_page.dart';
import 'package:campingneretva_desktop/screens/workers_page.dart';
import 'package:flutter/material.dart';
import 'package:campingneretva_desktop/screens/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:campingneretva_desktop/screens/parcel_page.dart';
import 'package:campingneretva_desktop/screens/dashboard_page.dart';
import 'package:campingneretva_desktop/widgets/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  runApp(AdminDesktopApp());
}

class AdminDesktopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: AppTheme.greenTheme,
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/prices': (context) => const PricePage(),
        '/facilities': (context) => const FacilityPage(),
        '/activities': (context) => const ActivityPage(),
        '/parcels': (context) => const ParcelPage(),
        '/rentableItems': (context) => const RentableItemsPage(),
        '/reservations': (context) => const ReservationsPage(),
        '/users': (context) => const UsersPage(),
        '/workers': (context) => const WorkersPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
