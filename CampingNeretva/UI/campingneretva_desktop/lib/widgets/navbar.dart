import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Map<String, String?> navRoutes = {
      "Cijene": '/prices',
      "Parcele": '/parcels',
      "Rezervacije": null,
      "Aktivnosti": '/activities',
      "Rentanje": null,
      "Radnici": null,
      "Korisnici": null,
      "Sadržaji": '/facilities',
      "O kampu": null,
    };

    return AppBar(
      backgroundColor: Colors.green,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            navRoutes.entries.map((entry) {
              final label = entry.key;
              final route = entry.value;
              return TextButton(
                onPressed:
                    route != null
                        ? () => Navigator.pushNamed(context, route)
                        : null,
                child: Text(label, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
      ),
    );
  }
}
