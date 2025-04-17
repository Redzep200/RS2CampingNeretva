import 'package:flutter/material.dart';
import '../models/parcel.dart';
import '../services/parcel_service.dart';

class ParcelListScreen extends StatelessWidget {
  const ParcelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parcels')),
      body: FutureBuilder<List<Parcel>>(
        future: ParcelService.fetchParcels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final parcels = snapshot.data!;

          return ListView.builder(
            itemCount: parcels.length,
            itemBuilder: (context, index) {
              final parcel = parcels[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Parcel #${parcel.parcelNumber}'),
                  subtitle: Text(
                    'Electricity: ${parcel.electricity}, Shade: ${parcel.shade}',
                  ),
                  leading:
                      parcel.images.isNotEmpty
                          ? Image.network(
                            parcel.images[0],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.image_not_supported),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
