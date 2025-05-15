import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final List<String> navItems = [
      "Cijene",
      "Parcele",
      "Rezervacije",
      "Aktivnosti",
      "Rentanje",
      "Radnici",
      "Korisnici",
      "Sadržaji",
      "O kampu",
    ];

    return AppBar(
      backgroundColor: Colors.green,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            navItems.map((item) {
              return TextButton(
                onPressed: () {
                  // You can use Navigator.pushNamed(context, '/route') later
                },
                child: Text(item, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
      ),
    );
  }
}
