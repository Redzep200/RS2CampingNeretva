import 'package:flutter/material.dart';
import 'package:campingneretva_mobile/models/rentable_item_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RentableItemDetailsDialog extends StatelessWidget {
  final RentableItem item;

  const RentableItemDetailsDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        item.imageUrl != null && item.imageUrl!.startsWith('/')
            ? "${dotenv.env['API_URL']!}${item.imageUrl}"
            : item.imageUrl ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Header
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
                        errorBuilder:
                            (_, __, ___) => Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50),
                            ),
                      )
                      : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Status
                    Chip(
                      label: Text(
                        item.availableQuantity > 0
                            ? 'Available'
                            : 'Not Available',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                          item.availableQuantity > 0
                              ? Colors.green
                              : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    // Details
                    _buildDetailRow(
                      'Available Quantity',
                      '${item.availableQuantity}',
                    ),
                    _buildDetailRow(
                      'Price per Day',
                      '\$${item.pricePerDay.toStringAsFixed(2)}',
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Close Button
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
