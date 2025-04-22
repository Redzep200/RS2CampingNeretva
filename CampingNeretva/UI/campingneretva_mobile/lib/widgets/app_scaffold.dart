import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          child: Column(
            children: [
              // Profile icon
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),

              // Buttons list
              Expanded(
                child: ListView(
                  children: const [
                    _DrawerItem(title: "Reservations", icon: Icons.book_online),
                    _DrawerItem(title: "Pitches", icon: Icons.terrain),
                    _DrawerItem(title: "Rate Employees", icon: Icons.star_rate),
                    _DrawerItem(
                      title: "Activities and renting",
                      icon: Icons.sports_kabaddi,
                    ),
                    _DrawerItem(title: "Facilities", icon: Icons.cabin),
                    _DrawerItem(
                      title: "Reservation history",
                      icon: Icons.history,
                    ),
                  ],
                ),
              ),

              // Bottom social links
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () {
                        _launchURL(
                          "https://www.google.com/maps/place/Neretva+Camping+for+tents+and+Motor+Homes/@43.3646723,17.815658,506m/data=!3m2!1e3!4b1!4m6!3m5!1s0x134b4321a14089d3:0x74d66a27338b237!8m2!3d43.3646723!4d17.815658!16s%2Fg%2F11h6nc72l9?entry=ttu&g_ep=EgoyMDI1MDQyMC4wIKXMDSoASAFQAw%3D%3D",
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {
                        _launchURL("https://www.instagram.com/campingneretva/");
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

  const _DrawerItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      onTap: () {
        // We'll wire these up later
        Navigator.pop(context);
      },
    );
  }
}
