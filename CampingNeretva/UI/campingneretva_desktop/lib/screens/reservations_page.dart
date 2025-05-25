import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../widgets/navbar.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  late Future<List<Reservation>> _reservationsFuture;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Filter states
  String _usernameFilter = '';
  String _reservationNumberFilter = '';
  String? _vehicleTypeFilter;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  void _fetchReservations() {
    setState(() {
      _reservationsFuture = ReservationService.fetchAll();
    });
  }

  String _getCategory(Reservation r) {
    final now = DateTime.now();
    if (r.endDate.isBefore(now)) return 'Past';
    if (r.startDate.isAfter(now)) return 'Upcoming';
    return 'Active';
  }

  List<Reservation> _applyFilters(List<Reservation> reservations) {
    return reservations.where((r) {
      final usernameMatch = '${r.user.firstName} ${r.user.lastName}'
          .toLowerCase()
          .contains(_usernameFilter.toLowerCase());
      final reservationNumberMatch = r.reservationId.toString().contains(
        _reservationNumberFilter.toLowerCase(),
      );
      final vehicleMatch =
          _vehicleTypeFilter == null ||
          r.vehicles.any(
            (v) =>
                v.vehicle.type.toLowerCase() ==
                _vehicleTypeFilter!.toLowerCase(),
          );
      final dateMatch =
          _selectedDate == null ||
          (_selectedDate!.isAfter(
                r.startDate.subtract(const Duration(days: 1)),
              ) &&
              _selectedDate!.isBefore(r.endDate.add(const Duration(days: 1))));
      return usernameMatch &&
          reservationNumberMatch &&
          vehicleMatch &&
          dateMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavbar(),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: FutureBuilder<List<Reservation>>(
              future: _reservationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No reservations found.'));
                }

                final filteredReservations = _applyFilters(snapshot.data!);

                final sorted = {
                  'Active': <Reservation>[],
                  'Upcoming': <Reservation>[],
                  'Past': <Reservation>[],
                };

                for (var r in filteredReservations) {
                  sorted[_getCategory(r)]!.add(r);
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children:
                      sorted.entries.expand<Widget>((entry) {
                        if (entry.value.isEmpty)
                          return const Iterable<Widget>.empty();
                        return [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...entry.value.map(_buildReservationCard),
                          const SizedBox(height: 20),
                        ];
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by username',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _usernameFilter = value;
                });
              },
            ),
          ),
          SizedBox(
            width: 200,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Reservation number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _reservationNumberFilter = value;
                });
              },
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _vehicleTypeFilter,
              items: const [
                DropdownMenuItem(value: null, child: Text('All Vehicles')),
                DropdownMenuItem(value: 'car', child: Text('Car')),
                DropdownMenuItem(value: 'motorbike', child: Text('Motorbike')),
                DropdownMenuItem(value: 'van', child: Text('Van')),
              ],
              onChanged: (value) {
                setState(() {
                  _vehicleTypeFilter = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(
                _selectedDate == null
                    ? 'Reservation Date'
                    : _dateFormat.format(_selectedDate!),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
          ),
          if (_selectedDate != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text("Clear Date"),
            ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation r) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          'Reservation #${r.reservationId} - ${r.user.firstName} ${r.user.lastName}',
        ),
        subtitle: Text(
          '${_dateFormat.format(r.startDate)} → ${_dateFormat.format(r.endDate)}',
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          _infoRow('Parcel', r.parcel.number.toString()),
          if (r.accommodations.isNotEmpty)
            _infoRow(
              'Accommodations',
              r.accommodations
                  .map((a) => '${a.accommodation.type} x${a.quantity}')
                  .join(', '),
            ),
          if (r.persons.isNotEmpty)
            _infoRow(
              'Persons',
              r.persons
                  .map((p) => '${p.person.type} x${p.quantity}')
                  .join(', '),
            ),
          if (r.vehicles.isNotEmpty)
            _infoRow(
              'Vehicles',
              r.vehicles
                  .map((v) => '${v.vehicle.type} x${v.quantity}')
                  .join(', '),
            ),
          if (r.rentableItems != null && r.rentableItems!.isNotEmpty)
            _infoRow(
              'Items',
              r.rentableItems!
                  .map((i) => '${i.item.name} x${i.quantity}')
                  .join(', '),
            ),
          if (r.activities != null && r.activities!.isNotEmpty)
            _infoRow('Activities', r.activities!.map((a) => a.name).join(', ')),
          _infoRow('Total Price', '${r.totalPrice.toStringAsFixed(2)} €'),
          _infoRow('Payment Status', r.paymentStatus),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(child: Text(content, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
