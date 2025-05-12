import 'package:campingneretva_mobile/models/acommodation_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campingneretva_mobile/models/parcel_accommodation_model.dart';
import '../models/activity_model.dart';
import '../models/parcel_model.dart';
import '../models/person_model.dart';
import 'package:campingneretva_mobile/models/rentable_item_model.dart';
import '../models/vehicle_model.dart';
import 'package:campingneretva_mobile/services/acommodation_service.dart';
import '../services/activity_service.dart';
import '../services/parcel_service.dart';
import '../services/person_service.dart';
import '../services/rentable_item_service.dart';
import '../services/vehicle_service.dart';
import '../services/reservation_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_scaffold.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime? startDate;
  DateTime? endDate;
  List<Parcel> parcels = [];
  List<Accommodation> accommodations = [];
  List<Activity> activities = [];
  List<RentableItem> rentItems = [];
  List<PersonType> persons = [];
  List<Vehicle> vehicles = [];

  Parcel? selectedParcel;
  Accommodation? selectedAccommodation;
  Vehicle? selectedVehicle;
  Map<int, int> selectedPersons = {};
  Map<int, int> selectedRentItems = {};
  Set<int> selectedActivities = {};

  bool get _datesSelected => startDate != null && endDate != null;

  double get totalPrice {
    if (!_datesSelected) return 0.0;
    final nights = endDate!.difference(startDate!).inDays;
    double total = 0;

    if (selectedAccommodation != null)
      total += selectedAccommodation!.price * nights;
    if (selectedVehicle != null) total += selectedVehicle!.price * nights;

    selectedPersons.forEach((id, count) {
      final p = persons.firstWhere((x) => x.id == id);
      total += p.price * count * nights;
    });

    selectedRentItems.forEach((id, count) {
      final r = rentItems.firstWhere((x) => x.id == id);
      total += r.pricePerDay * count * nights;
    });

    selectedActivities.forEach((id) {
      final a = activities.firstWhere((x) => x.id == id);
      total += a.price;
    });

    return total;
  }

  Future<void> _submitReservation() async {
    if (!_datesSelected ||
        selectedParcel == null ||
        selectedAccommodation == null)
      return;

    final payload = {
      'userId': AuthService.currentUser!.id,
      'CheckInDate': startDate!.toIso8601String(),
      'CheckOutDate': endDate!.toIso8601String(),
      'parcelId': selectedParcel!.id,
      'accommodations':
          selectedAccommodation != null
              ? [
                {'accommodationId': selectedAccommodation!.id, 'quantity': 1},
              ]
              : [],
      'vehicles':
          selectedVehicle != null
              ? [
                {'vehicleId': selectedVehicle!.id, 'quantity': 1},
              ]
              : [],
      'persons':
          selectedPersons.entries
              .map((e) => {'personId': e.key, 'quantity': e.value})
              .toList(),
      'rentableItems':
          selectedRentItems.entries
              .map((e) => {'itemId': e.key, 'quantity': e.value})
              .toList(),
      'activities': selectedActivities.map((id) => {'activityId': id}).toList(),
    };

    try {
      await ReservationService.insert(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation successful!')),
        );
        // Navigator.pushNamed(context, '/history');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to make reservation: \$e')),
        );
      }
    }
  }

  Future<void> _loadAll() async {
    if (!_datesSelected) return;

    parcels = await ParcelService.getParcels(from: startDate, to: endDate);
    parcels = parcels.where((p) => p.isAvailable).toList();

    accommodations = await AccommodationService.getAccommodations();
    activities = await ActivityService.getByDateRange(
      startDate!.toIso8601String(),
      endDate!.toIso8601String(),
    );
    activities =
        activities
            .where(
              (a) => a.date.isAfter(startDate!) && a.date.isBefore(endDate!),
            )
            .toList();

    rentItems = await RentableItemService.getAvailable(
      startDate!.toIso8601String(),
      endDate!.toIso8601String(),
    );
    persons = await PersonService.getPersons();
    vehicles = await VehicleService.getVehicles();
    setState(() {});
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        selectedParcel = null;
        selectedAccommodation = null;
        selectedVehicle = null;
        selectedPersons.clear();
        selectedRentItems.clear();
        selectedActivities.clear();
      });
      await _loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Make your reservation',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: _pickDateRange,
              child: Text(
                _datesSelected
                    ? 'From: ${DateFormat.yMd().format(startDate!)} - To: ${DateFormat.yMd().format(endDate!)}'
                    : 'Select reservation dates',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<Parcel>(
              value: selectedParcel,
              hint: Text(
                _datesSelected ? 'Select Parcel' : 'Select dates first',
              ),
              isExpanded: true,
              items:
                  parcels.map((parcel) {
                    return DropdownMenuItem(
                      value: parcel,
                      child: Text('Parcel ${parcel.number}'),
                    );
                  }).toList(),
              onChanged:
                  _datesSelected
                      ? (value) => setState(() => selectedParcel = value)
                      : null,
            ),
            DropdownButton<Accommodation>(
              value: selectedAccommodation,
              hint: Text(
                _datesSelected ? 'Select Accommodation' : 'Select dates first',
              ),
              isExpanded: true,
              items:
                  accommodations.map((a) {
                    return DropdownMenuItem(value: a, child: Text(a.type));
                  }).toList(),
              onChanged:
                  _datesSelected
                      ? (value) => setState(() => selectedAccommodation = value)
                      : null,
            ),
            DropdownButton<Vehicle>(
              value: selectedVehicle,
              hint: Text(
                _datesSelected ? 'Select Vehicle' : 'Select dates first',
              ),
              isExpanded: true,
              items:
                  vehicles.map((v) {
                    return DropdownMenuItem(value: v, child: Text(v.type));
                  }).toList(),
              onChanged:
                  _datesSelected
                      ? (value) => setState(() => selectedVehicle = value)
                      : null,
            ),
            const SizedBox(height: 16),
            if (_datesSelected)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Guests:'),
                  for (var p in persons)
                    Row(
                      children: [
                        Expanded(child: Text(p.type)),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              () => setState(() {
                                if ((selectedPersons[p.id] ?? 0) > 0) {
                                  selectedPersons[p.id] =
                                      (selectedPersons[p.id] ?? 0) - 1;
                                }
                              }),
                        ),
                        Text('${selectedPersons[p.id] ?? 0}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed:
                              () => setState(() {
                                selectedPersons[p.id] =
                                    (selectedPersons[p.id] ?? 0) + 1;
                              }),
                        ),
                      ],
                    ),
                ],
              ),
            const SizedBox(height: 16),
            if (_datesSelected) ...[
              const Text('Renting:'),
              for (var r in rentItems)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${r.name} (Available: ${r.availableQuantity})',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed:
                          () => setState(() {
                            if ((selectedRentItems[r.id] ?? 0) > 0) {
                              selectedRentItems[r.id] =
                                  (selectedRentItems[r.id] ?? 0) - 1;
                            }
                          }),
                    ),
                    Text('${selectedRentItems[r.id] ?? 0}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed:
                          () => setState(() {
                            selectedRentItems[r.id] =
                                (selectedRentItems[r.id] ?? 0) + 1;
                          }),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              const Text('Activities:'),
              for (var a in activities)
                CheckboxListTile(
                  title: Text(a.name),
                  value: selectedActivities.contains(a.id),
                  onChanged:
                      (selected) => setState(() {
                        if (selected == true) {
                          selectedActivities.add(a.id);
                        } else {
                          selectedActivities.remove(a.id);
                        }
                      }),
                ),
            ],
            const SizedBox(height: 24),
            if (_datesSelected)
              Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _datesSelected ? _submitReservation : null,
              child: const Text('Make reservation'),
            ),
          ],
        ),
      ),
    );
  }
}
