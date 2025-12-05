// campingneretva_desktop/lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campingneretva_desktop/screens/login_page.dart';
import 'package:campingneretva_desktop/screens/activity_page.dart';
import 'package:campingneretva_desktop/screens/facility_page.dart';
import 'package:campingneretva_desktop/screens/prices_page.dart';
import 'package:campingneretva_desktop/screens/rentable_item_page.dart';
import 'package:campingneretva_desktop/screens/reservations_page.dart';
import 'package:campingneretva_desktop/screens/users_page.dart';
import 'package:campingneretva_desktop/screens/workers_page.dart';
import 'package:campingneretva_desktop/screens/parcel_page.dart';
import 'package:campingneretva_desktop/screens/dashboard_page.dart';
import 'package:campingneretva_desktop/screens/activity_notifications_page.dart';
import 'package:campingneretva_desktop/widgets/app_theme.dart';
import 'package:campingneretva_desktop/services/notification_subscriber.dart';
import 'package:campingneretva_desktop/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load(fileName: ".env");

  // Initialize Hive (for storing login)
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  runApp(const AdminDesktopApp());
}

class AdminDesktopApp extends StatefulWidget {
  const AdminDesktopApp({super.key});

  @override
  State<AdminDesktopApp> createState() => _AdminDesktopAppState();
}

class _AdminDesktopAppState extends State<AdminDesktopApp> {
  @override
  void initState() {
    super.initState();
    // Try to restore session (auto-login if credentials saved)
    AuthService.tryRestoreSession().then((loggedIn) {
      if (loggedIn && mounted) {
        // Start real-time notifications as soon as user is logged in
        NotificationSubscriber.initialize(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camping Neretva • Admin Panel',
      theme: AppTheme.greenTheme,
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/prices': (_) => const PricePage(),
        '/facilities': (_) => const FacilityPage(),
        '/activities': (_) => const ActivityPage(),
        '/parcels': (_) => const ParcelPage(),
        '/rentableItems': (_) => const RentableItemsPage(),
        '/reservations': (_) => const ReservationsPage(),
        '/users': (_) => const UsersPage(),
        '/workers': (_) => const WorkersPage(),
        '/dashboard': (_) => const DashboardPage(),
        '/notifications': (_) => const ActivityNotificationsPage(),
      },
      builder: (context, child) {
        // This widget wraps every page and ensures notifications work everywhere
        return NotificationListenerOverlay(child: child!);
      },
    );
  }
}

/// This widget listens to login state and starts RabbitMQ listener
class NotificationListenerOverlay extends StatefulWidget {
  final Widget child;
  const NotificationListenerOverlay({required this.child, super.key});

  @override
  State<NotificationListenerOverlay> createState() =>
      _NotificationListenerOverlayState();
}

class _NotificationListenerOverlayState
    extends State<NotificationListenerOverlay> {
  bool _hasStartedListener = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Start RabbitMQ listener only once when user is logged in
    if (AuthService.isLoggedIn() && !_hasStartedListener) {
      _hasStartedListener = true;
      print("Starting real-time AI notification listener...");
      NotificationSubscriber.initialize(context);
    }

    // If user logs out → reset so it can restart on next login
    if (!AuthService.isLoggedIn()) {
      _hasStartedListener = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
