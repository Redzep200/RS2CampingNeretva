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
  int _currentPage = 0;
  final int _pageSize = 4;
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations({DateTime? checkInDate}) {
    setState(() {
      _reservationsFuture = ReservationService.getByUserId(
        AuthService.currentUser!.id,
        page: _currentPage,
        pageSize: _pageSize,
        checkInDate: checkInDate,
      );
    });
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
        _currentPage = 0;
        _loadReservations(checkInDate: _selectedDate);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reservation History',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Search by Check-in Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _dateController.clear();
                        _currentPage = 0;
                        _loadReservations();
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Reservation>>(
              future: _reservationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error fetching reservations: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 40),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () =>
                                  _loadReservations(checkInDate: _selectedDate),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print(
                    'No reservations found for page: $_currentPage, date: $_selectedDate',
                  );
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, color: Colors.grey, size: 40),
                        SizedBox(height: 16),
                        Text('No reservations found.'),
                      ],
                    ),
                  );
                }

                final reservations = snapshot.data!;
                print('Reservations loaded: ${reservations.length}');

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: reservations.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final r = reservations[index];
                          final isExpanded = _expandedReservations.contains(
                            r.reservationId,
                          );
                          final totalPrice = calculateTotalPrice(r);

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: const Icon(
                                  Icons.history,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  'Reservation #${r.reservationId}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  '${r.startDate.toLocal().toString().split(' ')[0]} → ${r.endDate.toLocal().toString().split(' ')[0]}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                childrenPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                children: [
                                  _infoRow(
                                    const Icon(Icons.landscape, size: 20),
                                    'Parcel',
                                    r.parcel.number.toString(),
                                  ),
                                  _infoRow(
                                    const Icon(Icons.hotel, size: 20),
                                    'Accommodation',
                                    r.accommodation.type,
                                  ),
                                  if (r.persons.isNotEmpty)
                                    _infoRow(
                                      const Icon(Icons.people, size: 20),
                                      'Persons',
                                      r.persons.map((p) => p.type).join(', '),
                                    ),
                                  if (r.vehicles.isNotEmpty)
                                    _infoRow(
                                      const Icon(
                                        Icons.directions_car,
                                        size: 20,
                                      ),
                                      'Vehicles',
                                      r.vehicles.map((v) => v.type).join(', '),
                                    ),
                                  if (r.rentableItems.isNotEmpty)
                                    _infoRow(
                                      const Icon(Icons.shopping_bag, size: 20),
                                      'Items',
                                      r.rentableItems
                                          .map((i) => i.name)
                                          .join(', '),
                                    ),
                                  if (r.activities.isNotEmpty)
                                    _infoRow(
                                      const Icon(Icons.event, size: 20),
                                      'Activities',
                                      r.activities
                                          .map((a) => a.name)
                                          .join(', '),
                                    ),
                                  _infoRow(
                                    const Icon(Icons.attach_money, size: 20),
                                    'Total Price',
                                    '${totalPrice.toStringAsFixed(2)} €',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            onPressed:
                                _currentPage > 0
                                    ? () {
                                      setState(() {
                                        _currentPage--;
                                        _loadReservations(
                                          checkInDate: _selectedDate,
                                        );
                                      });
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              disabledForegroundColor: Colors.grey,
                            ),
                          ),
                          Text(
                            'Page ${_currentPage + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                            onPressed:
                                reservations.length == _pageSize
                                    ? () {
                                      setState(() {
                                        _currentPage++;
                                        _loadReservations(
                                          checkInDate: _selectedDate,
                                        );
                                      });
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              disabledForegroundColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(Widget icon, String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          SizedBox(
            width: 120, // Fixed width ensures alignment
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Reservation r) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text(
              'Are you sure you want to delete this reservation? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Add deletion logic here
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
