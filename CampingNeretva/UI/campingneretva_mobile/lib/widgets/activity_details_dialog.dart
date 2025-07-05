import 'package:flutter/material.dart';
import 'package:campingneretva_mobile/models/activity_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActivityDetailsDialog extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsDialog({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        activity.imageUrl != null && activity.imageUrl!.startsWith('/')
            ? "${dotenv.env['API_URL']!}${activity.imageUrl}"
            : activity.imageUrl ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                      : _placeholderImage(),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Chip(
                      label: const Text(
                        'Available',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    const SizedBox(height: 16),

                    _buildIconDetailRow(
                      Icons.calendar_today,
                      'Date',
                      DateFormat('dd.MM.yyyy').format(activity.date),
                    ),
                    _buildIconDetailRow(
                      Icons.attach_money,
                      'Price',
                      '\$${activity.price.toStringAsFixed(2)}',
                    ),

                    if (activity.description.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, size: 50),
    );
  }

  Widget _buildIconDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
