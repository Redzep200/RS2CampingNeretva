import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../widgets/navbar.dart';
import '../widgets/app_theme.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  late Future<List<Reservation>> _reservationsFuture;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalItems = 0;
  List<Reservation> _allReservations = [];
  List<Reservation> _filteredReservations = [];

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
      _reservationsFuture = ReservationService.fetchAll(
        page: 0,
        pageSize: 10000,
      );
    });
  }

  String _getCategory(Reservation r) {
    final now = DateTime.now();
    if (r.endDate.isBefore(now)) return 'Istekle';
    if (r.startDate.isAfter(now)) return 'Buduće';
    return 'Aktivne';
  }

  List<Reservation> _applyFilters(List<Reservation> reservations) {
    var filtered =
        reservations.where((r) {
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
                  _selectedDate!.isBefore(
                    r.endDate.add(const Duration(days: 1)),
                  ));
          return usernameMatch &&
              reservationNumberMatch &&
              vehicleMatch &&
              dateMatch;
        }).toList();
    _filteredReservations = filtered;
    _totalItems = filtered.length;
    return filtered;
  }

  int _calculateNights(Reservation r) {
    return r.endDate.difference(r.startDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(),
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
                  return Center(child: Text('Greška: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Nije pronađena ni jedna rezervacija.'),
                  );
                }

                _allReservations = snapshot.data!;
                final filteredReservations = _applyFilters(_allReservations);

                final sorted = {
                  'Aktivne': <Reservation>[],
                  'Buduće': <Reservation>[],
                  'Istekle': <Reservation>[],
                };

                for (var r in filteredReservations) {
                  sorted[_getCategory(r)]!.add(r);
                }

                final startIndex = _currentPage * _pageSize;
                final endIndex =
                    startIndex + _pageSize > _totalItems
                        ? _totalItems
                        : startIndex + _pageSize;
                final paginatedReservations = filteredReservations.sublist(
                  startIndex,
                  endIndex,
                );

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children:
                            sorted.entries.expand<Widget>((entry) {
                              if (entry.value.isEmpty) {
                                return const Iterable<Widget>.empty();
                              }
                              return [
                                Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...paginatedReservations
                                    .where((r) => _getCategory(r) == entry.key)
                                    .map(_buildReservationCard),
                                const SizedBox(height: 20),
                              ];
                            }).toList(),
                      ),
                    ),
                    _buildPaginationControls(),
                  ],
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
                labelText: 'Pretraga po korisničkom imenu',
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                setState(() {
                  _usernameFilter = value;
                  _currentPage = 0;
                });
              },
            ),
          ),
          SizedBox(
            width: 200,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Broj rezervacije',
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _reservationNumberFilter = value;
                  _currentPage = 0;
                });
              },
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _vehicleTypeFilter,
              items: const [
                DropdownMenuItem(value: null, child: Text('Sva vozila')),
                DropdownMenuItem(value: 'car', child: Text('Auto')),
                DropdownMenuItem(value: 'motorbike', child: Text('Motocikl')),
                DropdownMenuItem(value: 'van', child: Text('Kombi')),
              ],
              onChanged: (value) {
                setState(() {
                  _vehicleTypeFilter = value;
                  _currentPage = 0;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Tip vozila',
                prefixIcon: Icon(Icons.directions_car),
              ),
              style: const TextStyle(color: Colors.black87),
              dropdownColor: Colors.white,
            ),
          ),
          SizedBox(
            width: 200,
            child: OutlinedButton.icon(
              style: Theme.of(context).outlinedButtonTheme.style,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Datum rezervacije'
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
                    _currentPage = 0;
                  });
                }
              },
            ),
          ),
          if (_selectedDate != null)
            TextButton.icon(
              style: AppTheme.greenTextButtonStyle,
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                  _currentPage = 0;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Ukloni datum'),
            ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation r) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: const Icon(Icons.local_activity, color: Colors.blue),
          title: Text(
            'Rezervacija #${r.reservationId} - ${r.user.firstName} ${r.user.lastName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            '${_dateFormat.format(r.startDate)} → ${_dateFormat.format(r.endDate)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            if (r.accommodations.isNotEmpty)
              _infoRow(
                const Icon(Icons.hotel, size: 20),
                'Smještaj',
                r.accommodations
                    .map((a) => '${a.accommodation.type} x${a.quantity}')
                    .join(', '),
              ),
            if (r.persons.isNotEmpty)
              _infoRow(
                const Icon(Icons.people, size: 20),
                'Osobe',
                r.persons
                    .map((p) => '${p.person.type} x${p.quantity}')
                    .join(', '),
              ),
            if (r.vehicles.isNotEmpty)
              _infoRow(
                const Icon(Icons.directions_car, size: 20),
                'Vozila',
                r.vehicles
                    .map((v) => '${v.vehicle.type} x${v.quantity}')
                    .join(', '),
              ),
            if (r.rentableItems != null && r.rentableItems!.isNotEmpty)
              _infoRow(
                const Icon(Icons.shopping_bag, size: 20),
                'Iznajmljive stavke',
                r.rentableItems!
                    .map((i) => '${i.item.name} x${i.quantity}')
                    .join(', '),
              ),
            if (r.activities != null && r.activities!.isNotEmpty)
              _infoRow(
                const Icon(Icons.event, size: 20),
                'Aktivnosti',
                r.activities!.map((a) => a.name).join(', '),
              ),
            _infoRow(
              const Icon(Icons.nights_stay, size: 20),
              'Broj noći',
              _calculateNights(r).toString(),
            ),
            _infoRow(
              const Icon(Icons.attach_money, size: 20),
              'Cijena',
              '${r.totalPrice.toStringAsFixed(2)} €',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(Widget icon, String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 8),
          SizedBox(
            width: 120, // fixed width for label column
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
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_totalItems / _pageSize).ceil();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            style: AppTheme.greenIconButtonStyle,
            icon: const Icon(Icons.arrow_back),
            onPressed:
                _currentPage > 0
                    ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                    : null,
          ),
          Text('Stranica ${_currentPage + 1} od $totalPages'),
          IconButton(
            style: AppTheme.greenIconButtonStyle,
            icon: const Icon(Icons.arrow_forward),
            onPressed:
                _currentPage < (totalPages - 1)
                    ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
