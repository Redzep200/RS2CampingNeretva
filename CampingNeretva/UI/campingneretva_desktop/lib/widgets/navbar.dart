// widgets/navbar.dart
import 'package:flutter/material.dart';
import '../services/activity_analysis_service.dart';
import 'dart:async';

class CustomNavbar extends StatefulWidget implements PreferredSizeWidget {
  const CustomNavbar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  int _notificationCount = 0;
  Timer? _refreshTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadNotificationCount();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotificationCount() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      // CHANGED: now uses getNotifications() → returns list → count length
      final notifications = await ActivityAnalysisService.getNotifications();
      if (mounted) {
        setState(() {
          _notificationCount =
              notifications.length; // ← this is the only real change
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notification count: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String?> navRoutes = {
      "Cijene": '/prices',
      "Parcele": '/parcels',
      "Rezervacije": '/reservations',
      "Aktivnosti": '/activities',
      "Rentanje": '/rentableItems',
      "Radnici": '/workers',
      "Korisnici": '/users',
      "Sadržaji": '/facilities',
      "Notifikacije": '/notifications',
      "O kampu": '/dashboard',
    };

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            navRoutes.entries.map((entry) {
              final label = entry.key;
              final route = entry.value;
              final isNotifications = label == "Notifikacije";

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  TextButton(
                    onPressed:
                        route != null
                            ? () async {
                              Navigator.pushNamed(context, route);
                              if (isNotifications) {
                                // Badge disappears immediately when you click it
                                setState(() => _notificationCount = 0);
                                // Then refresh real count after page loads
                                await Future.delayed(
                                  const Duration(seconds: 1),
                                );
                                _loadNotificationCount();
                              }
                            }
                            : null,
                    child: Text(
                      label,
                      style:
                          Theme.of(context).textButtonTheme.style?.textStyle
                              ?.resolve({})
                              ?.copyWith(color: Colors.white) ??
                          const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (isNotifications && _notificationCount > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          _notificationCount > 9 ? '9+' : '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
      ),
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
