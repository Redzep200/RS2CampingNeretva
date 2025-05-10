import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import 'package:campingneretva_mobile/screens/login_page.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({super.key, required this.title, required this.body});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              final isLoggedIn = AuthService.isLoggedIn();
              final user = AuthService.currentUser;

              return Column(
                children: [
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      if (isLoggedIn) {
                        Navigator.pushNamed(context, '/profile');
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => const LoginPage(),
                        ).then((_) => setState(() {})); // Refresh after login
                      }
                    },
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isLoggedIn
                              ? "${user!.firstName} ${user.lastName}"
                              : "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: isLoggedIn ? Colors.black : Colors.blue,
                            decoration:
                                isLoggedIn
                                    ? TextDecoration.none
                                    : TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Drawer items
                  Expanded(
                    child: ListView(
                      children: [
                        if (isLoggedIn)
                          _DrawerItem(
                            title: "Reservations",
                            icon: Icons.book_online,
                          ),
                        _DrawerItem(
                          title: "Parcels",
                          icon: Icons.terrain,
                          onTap: () {
                            Navigator.pushNamed(context, '/parcels');
                          },
                        ),
                        if (isLoggedIn)
                          _DrawerItem(
                            title: "Rate Employees",
                            icon: Icons.star_rate,
                            onTap: () {
                              Navigator.pushNamed(context, '/review');
                            },
                          ),
                        _DrawerItem(
                          title: "Activities and renting",
                          icon: Icons.sports_kabaddi,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/activities-rentables',
                            );
                          },
                        ),
                        _DrawerItem(
                          title: "Facilities",
                          icon: Icons.cabin,
                          onTap: () {
                            Navigator.pushNamed(context, '/facilities');
                          },
                        ),
                        if (isLoggedIn)
                          _DrawerItem(
                            title: "Reservation history",
                            icon: Icons.history,
                          ),
                      ],
                    ),
                  ),

                  if (isLoggedIn)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text("Log Out"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          AuthService.logout();
                          setState(() {});
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                    ),

                  // Social links
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: () {
                            _launchURL(
                              "https://www.google.com/maps/place/Neretva+Camping...",
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () {
                            _launchURL(
                              "https://www.instagram.com/campingneretva/",
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.facebook),
                          onPressed: () {
                            _launchURL(
                              "https://www.facebook.com/search/top?q=camping%20neretva",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),

      appBar: AppBar(
        title: Text(title),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
      body: body,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _DrawerItem({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}
