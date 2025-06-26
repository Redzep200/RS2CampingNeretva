import 'package:flutter/material.dart';
import '../models/parcel_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParcelDetailsDialog extends StatelessWidget {
  final Parcel parcel;

  const ParcelDetailsDialog({super.key, required this.parcel});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        parcel.imageUrl != null && parcel.imageUrl!.startsWith('/')
            ? "${dotenv.env['API_URL']!}${parcel.imageUrl}"
            : parcel.imageUrl ?? '';

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
            // Image
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

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Parcel #${parcel.number}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Availability
                    Chip(
                      label: Text(
                        parcel.isAvailable ? 'Available' : 'Not Available',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                          parcel.isAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 16),

                    // Parcel Details
                    _buildIconDetailRow(
                      Icons.category,
                      'Type',
                      parcel.parcelType,
                    ),
                    _buildIconDetailRow(
                      Icons.king_bed,
                      'Accommodation',
                      parcel.parcelAccommodation,
                    ),
                    _buildIconDetailRow(
                      Icons.park,
                      'Shade',
                      parcel.shade ? 'Yes' : 'No',
                    ),
                    _buildIconDetailRow(
                      Icons.flash_on,
                      'Electricity',
                      parcel.electricity ? 'Yes' : 'No',
                    ),

                    if (parcel.description != null &&
                        parcel.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        parcel.description!,
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

  Widget _placeholderImage() {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 50),
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
