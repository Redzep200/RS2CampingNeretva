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
      "Rezervacije": '/reservations',
      "Aktivnosti": '/activities',
      "Rentanje": '/rentableItems',
      "Radnici": '/workers',
      "Korisnici": '/users',
      "Sadržaji": '/facilities',
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
              return TextButton(
                onPressed:
                    route != null
                        ? () => Navigator.pushNamed(context, route)
                        : null,
                child: Text(
                  label,
                  style:
                      Theme.of(context).textButtonTheme.style?.textStyle
                          ?.resolve({})
                          ?.copyWith(color: Colors.white) ??
                      const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
      ),
    );
  }
}
