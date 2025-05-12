import 'package:flutter/material.dart';
import '../models/reservation_model.dart';
import '../services/auth_service.dart';
import '../services/reservation_service.dart';
import '../widgets/app_scaffold.dart';

class ReservationHistoryPage extends StatefulWidget {
  const ReservationHistoryPage({super.key});

  @override
  State<ReservationHistoryPage> createState() => _ReservationHistoryPageState();
}

class _ReservationHistoryPageState extends State<ReservationHistoryPage> {
  late Future<List<Reservation>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _reservationsFuture = ReservationService.getByUserId(
      AuthService.currentUser!.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reservation History',
      body: FutureBuilder<List<Reservation>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error during reservation fetch: ${snapshot.error}');
            print('StackTrace: ${snapshot.stackTrace}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reservations found.'));
          }

          final reservations = snapshot.data!;

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final r = reservations[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parcel: ${r.parcel.number}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Accommodation: ${r.accommodation.type}'),
                      Text(
                        'From: ${r.startDate.toLocal().toString().split(' ')[0]}',
                      ),
                      Text(
                        'To: ${r.endDate.toLocal().toString().split(' ')[0]}',
                      ),
                      const SizedBox(height: 8),
                      if (r.persons.isNotEmpty)
                        Text(
                          'Persons: ${r.persons.map((p) => p.type).join(', ')}',
                        ),
                      if (r.vehicles.isNotEmpty)
                        Text(
                          'Vehicles: ${r.vehicles.map((v) => v.type).join(', ')}',
                        ),
                      if (r.rentableItems.isNotEmpty)
                        Text(
                          'Items: ${r.rentableItems.map((i) => i.name).join(', ')}',
                        ),
                      if (r.activities.isNotEmpty)
                        Text(
                          'Activities: ${r.activities.map((a) => a.name).join(', ')}',
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
