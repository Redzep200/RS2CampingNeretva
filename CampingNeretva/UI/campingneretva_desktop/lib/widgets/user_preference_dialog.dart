import 'package:flutter/material.dart';
import '../models/user_preference_model.dart';

class UserPreferenceDialog extends StatelessWidget {
  final UserPreferenceModel preference;

  const UserPreferenceDialog({Key? key, required this.preference})
    : super(key: key);

  Widget _buildItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.favorite, color: Colors.teal),
          SizedBox(width: 8),
          Text('Korisničke Preferencije'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem(
            Icons.people,
            'Broj osoba:',
            '${preference.numberOfPeople}',
          ),
          _buildItem(
            Icons.child_care,
            'Djeca:',
            preference.hasSmallChildren ? 'Da' : 'Ne',
          ),
          _buildItem(
            Icons.elderly,
            'Stariji putnici:',
            preference.hasSeniorTravelers ? 'Da' : 'Ne',
          ),
          _buildItem(
            Icons.directions_car,
            'Dužina auta:',
            preference.carLength,
          ),
          _buildItem(Icons.pets, 'Psi:', preference.hasDogs ? 'Da' : 'Ne'),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('Zatvori'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
