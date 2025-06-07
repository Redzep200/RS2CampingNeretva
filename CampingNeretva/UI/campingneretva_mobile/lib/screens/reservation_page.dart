import 'package:campingneretva_mobile/models/acommodation_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campingneretva_mobile/models/parcel_model.dart';
import 'package:campingneretva_mobile/models/person_model.dart';
import 'package:campingneretva_mobile/models/rentable_item_model.dart';
import 'package:campingneretva_mobile/models/vehicle_model.dart';
import 'package:campingneretva_mobile/models/activity_model.dart';
import 'package:campingneretva_mobile/services/acommodation_service.dart';
import 'package:campingneretva_mobile/services/activity_service.dart';
import 'package:campingneretva_mobile/services/parcel_service.dart';
import 'package:campingneretva_mobile/services/person_service.dart';
import 'package:campingneretva_mobile/services/rentable_item_service.dart';
import 'package:campingneretva_mobile/services/vehicle_service.dart';
import 'package:campingneretva_mobile/services/reservation_service.dart';
import 'package:campingneretva_mobile/services/auth_service.dart';
import 'package:campingneretva_mobile/widgets/app_scaffold.dart';
import '../services/payment_service.dart';
import 'paypal_webview.dart';
import '../screens/reservation_history_page.dart';

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

  bool _isProcessingPayment = false;
  int? _currentReservationId;

  bool get _datesSelected => startDate != null && endDate != null;

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
      'accommodations': [
        {'accommodationId': selectedAccommodation!.id, 'quantity': 1},
      ],
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
      final reservation = await ReservationService.insert(payload);

      // Extract reservation ID (adjust based on your ReservationService response structure)
      final reservationId = reservation['id'] ?? reservation['reservationId'];

      if (reservationId != null) {
        setState(() {
          _currentReservationId = reservationId;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservation created! Proceed to payment.'),
            ),
          );
        }

        // Automatically start payment process
        await _startPayPalPayment();
      } else {
        throw Exception('Failed to get reservation ID');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to make reservation: $e')),
        );
      }
    }
  }

  Future<void> _startPayPalPayment() async {
    if (_currentReservationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No reservation found. Please try again.'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final orderResponse = await PaymentService.createPayPalOrder(
        reservationId: _currentReservationId!,
        amount: estimatedTotal,
        currency: 'EUR',
      );

      final approvalUrl = orderResponse['approvalUrl'] as String;
      final orderId = orderResponse['orderId'] as String;

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => PayPalWebView(
                  approvalUrl: approvalUrl,
                  returnUrl: 'myapp://paypal-success',
                  cancelUrl: 'myapp://paypal-cancel',
                  onSuccess: (returnedOrderId) async {
                    Navigator.of(context).pop();
                    await _capturePayment(orderId);
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isProcessingPayment = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment cancelled')),
                    );
                  },
                  onError: (error) {
                    Navigator.of(context).pop();
                    setState(() {
                      _isProcessingPayment = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment error: $error')),
                    );
                  },
                ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start payment: $e')));
      }
    }
  }

  Future<void> _capturePayment(String orderId) async {
    try {
      final captureResponse = await PaymentService.capturePayPalOrder(
        orderId: orderId,
        reservationId: _currentReservationId!,
      );

      setState(() {
        _isProcessingPayment = false;
      });

      if (captureResponse['status'] == 'COMPLETED') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Payment successful! Your reservation is confirmed.',
              ),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ReservationHistoryPage(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        throw Exception('Payment capture failed');
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete payment: $e')),
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
              (a) => !a.date.isBefore(startDate!) && !a.date.isAfter(endDate!),
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
        _currentReservationId = null;
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
            _buildDropdown<Parcel>(
              label: 'Select Parcel',
              value: selectedParcel,
              items: parcels,
              itemBuilder: (p) => 'Parcel ${p.number}',
              onChanged:
                  _datesSelected
                      ? (p) => setState(() => selectedParcel = p)
                      : null,
            ),
            _buildDropdown<Accommodation>(
              label: 'Select Accommodation',
              value: selectedAccommodation,
              items: accommodations,
              itemBuilder: (a) => a.type,
              onChanged:
                  _datesSelected
                      ? (a) => setState(() => selectedAccommodation = a)
                      : null,
            ),
            _buildDropdown<Vehicle>(
              label: 'Select Vehicle',
              value: selectedVehicle,
              items: vehicles,
              itemBuilder: (v) => v.type,
              onChanged:
                  _datesSelected
                      ? (v) => setState(() => selectedVehicle = v)
                      : null,
            ),
            const SizedBox(height: 16),
            if (_datesSelected)
              _buildCounterSection('Guests:', persons, selectedPersons),
            if (_datesSelected)
              _buildCounterSection(
                'Renting:',
                rentItems,
                selectedRentItems,
                isRentItem: true,
              ),
            if (_datesSelected) _buildActivitySection(),
            const SizedBox(height: 24),
            if (_datesSelected)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Amount: ${estimatedTotal.toStringAsFixed(2)} KM',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'MochiyPop',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_currentReservationId != null)
                      Text(
                        'Reservation ID: $_currentReservationId',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (_datesSelected && _currentReservationId == null)
              ElevatedButton(
                onPressed: _submitReservation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Create Reservation',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            if (_currentReservationId != null && !_isProcessingPayment)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _startPayPalPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment),
                        const SizedBox(width: 8),
                        const Text(
                          'Pay with PayPal',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentReservationId = null;
                      });
                    },
                    child: const Text('Cancel Reservation'),
                  ),
                ],
              ),
            if (_isProcessingPayment)
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Processing payment...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items:
            items
                .map(
                  (e) =>
                      DropdownMenuItem(value: e, child: Text(itemBuilder(e))),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCounterSection(
    String label,
    List items,
    Map<int, int> selectedMap, {
    bool isRentItem = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        for (var item in items)
          Row(
            children: [
              Expanded(child: Text(isRentItem ? item.name : item.type)),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed:
                    () => setState(() {
                      final id = item.id;
                      if ((selectedMap[id] ?? 0) > 0) {
                        selectedMap[id] = (selectedMap[id] ?? 0) - 1;
                      }
                    }),
              ),
              Text('${selectedMap[item.id] ?? 0}'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed:
                    () => setState(() {
                      final id = item.id;
                      selectedMap[id] = (selectedMap[id] ?? 0) + 1;
                    }),
              ),
            ],
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activities:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
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
    );
  }

  double get estimatedTotal {
    if (!_datesSelected) return 0.0;
    final nights = endDate!.difference(startDate!).inDays;
    double total = 0;

    if (selectedAccommodation != null) {
      total += selectedAccommodation!.price * nights;
    }

    if (selectedVehicle != null) {
      total += selectedVehicle!.price * nights;
    }

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
}
