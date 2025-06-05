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
  final Set<int> _expandedReservations = {};

  @override
  void initState() {
    super.initState();
    _reservationsFuture = ReservationService.getByUserId(
      AuthService.currentUser!.id,
    );
  }

  double calculateTotalPrice(Reservation r) {
    final nights = r.endDate.difference(r.startDate).inDays;
    double total = 0;

    total += r.accommodation.price * nights;
    total += r.vehicles.fold(0, (sum, v) => sum + (v.price * nights));
    total += r.persons.fold(0, (sum, p) => sum + (p.price * nights));
    total += r.rentableItems.fold(
      0,
      (sum, i) => sum + (i.pricePerDay * nights),
    );
    total += r.activities.fold(0, (sum, a) => sum + a.price);

    return total;
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reservations found.'));
          }

          final reservations = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = reservations[index];
              final isExpanded = _expandedReservations.contains(
                r.reservationId,
              );
              final totalPrice = calculateTotalPrice(r);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parcel: ${r.parcel.number}',
                        style: const TextStyle(
                          fontFamily: 'MochiyPop',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Accommodation: ${r.accommodation.type}',
                        style: const TextStyle(
                          fontFamily: 'MochiyPop',
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'From: ${r.startDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'MochiyPop',
                        ),
                      ),
                      Text(
                        'To: ${r.endDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'MochiyPop',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Price: ${totalPrice.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'MochiyPop',
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedReservations.remove(r.reservationId);
                            } else {
                              _expandedReservations.add(r.reservationId);
                            }
                          });
                        },
                        icon: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        label: Text(
                          isExpanded ? 'Hide Add-ons' : 'Show Add-ons',
                        ),
                      ),
                      if (isExpanded) ...[
                        if (r.persons.isNotEmpty)
                          Text(
                            'Persons: ${r.persons.map((p) => p.type).join(', ')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'MochiyPop',
                            ),
                          ),
                        if (r.vehicles.isNotEmpty)
                          Text(
                            'Vehicles: ${r.vehicles.map((v) => v.type).join(', ')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'MochiyPop',
                            ),
                          ),
                        if (r.rentableItems.isNotEmpty)
                          Text(
                            'Items: ${r.rentableItems.map((i) => i.name).join(', ')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'MochiyPop',
                            ),
                          ),
                        if (r.activities.isNotEmpty)
                          Text(
                            'Activities: ${r.activities.map((a) => a.name).join(', ')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'MochiyPop',
                            ),
                          ),
                      ],
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
