import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/parcel_model.dart';
import '../services/parcel_service.dart';
import '../widgets/app_scaffold.dart';
import 'package:campingneretva_mobile/services/parcel_accommodation_service.dart';
import 'package:campingneretva_mobile/services/parcel_type_service.dart';
import 'package:campingneretva_mobile/models/parcel_accommodation_model.dart';
import 'package:campingneretva_mobile/models/parcel_type_model.dart';

class ParcelsPage extends StatefulWidget {
  const ParcelsPage({super.key});

  @override
  State<ParcelsPage> createState() => _ParcelsPageState();
}

class _ParcelsPageState extends State<ParcelsPage> {
  final ParcelService _parcelService = ParcelService();
  final _accommodationService = ParcelAccommodationService();
  final _typeService = ParcelTypeService();
  List<Parcel> parcels = [];
  List<ParcelAccommodation> _accommodations = [];
  List<ParcelType> _types = [];

  ParcelAccommodation? _selectedAccommodation;
  ParcelType? _selectedType;
  bool isLoading = true;

  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool? _shade;
  bool? _electricity;

  Future<void> _loadParcels() async {
    setState(() => isLoading = true);

    try {
      final data = await ParcelService.getParcels(
        from: _dateFrom,
        to: _dateTo,
        shade: _shade,
        electricity: _electricity,
        accommodation: _selectedAccommodation?.name,
        type: _selectedType?.name,
      );
      setState(() {
        parcels = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading parcels: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFilters();
    _loadParcels();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dateFrom = picked.start;
        _dateTo = picked.end;
      });
      _loadParcels();
    }
  }

  Future<void> _fetchFilters() async {
    try {
      final a = await _accommodationService.getAccommodations();
      final t = await _typeService.getParcelTypes();

      debugPrint("Accommodations loaded: ${a.length}");
      debugPrint("Types loaded: ${t.length}");

      setState(() {
        _accommodations = a;
        _types = t;
      });
    } catch (e) {
      debugPrint("Error fetching filter options: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Parcels',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _dateFrom != null && _dateTo != null
                        ? '${DateFormat('dd.MM').format(_dateFrom!)} - ${DateFormat('dd.MM').format(_dateTo!)}'
                        : "Pick date range",
                  ),
                  onPressed: _selectDateRange,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 150),
                  child: DropdownButtonFormField<ParcelAccommodation>(
                    decoration: const InputDecoration(
                      labelText: "Accommodation",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: _selectedAccommodation,
                    onChanged: (value) {
                      setState(() => _selectedAccommodation = value);
                      _loadParcels();
                    },
                    items:
                        _accommodations
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                  ),
                ),

                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 150),
                  child: DropdownButtonFormField<ParcelType>(
                    decoration: const InputDecoration(
                      labelText: "Parcel Type",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: _selectedType,
                    onChanged: (value) {
                      setState(() => _selectedType = value);
                      _loadParcels();
                    },
                    items:
                        _types
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                  ),
                ),
                FilterChip(
                  label: const Text("Shade"),
                  selected: _shade == true,
                  onSelected: (selected) {
                    setState(() {
                      _shade = selected ? true : null;
                    });
                    _loadParcels();
                  },
                ),
                FilterChip(
                  label: const Text("Electricity"),
                  selected: _electricity == true,
                  onSelected: (selected) {
                    setState(() {
                      _electricity = selected ? true : null;
                    });
                    _loadParcels();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: parcels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final parcel = parcels[index];
                    final imageUrl =
                        parcel.imageUrl.startsWith('/')
                            ? "http://192.168.0.15:5205${parcel.imageUrl}"
                            : parcel.imageUrl;

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Parcel #${parcel.number}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
