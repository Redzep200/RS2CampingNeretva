import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/parcel_model.dart';
import '../services/parcel_service.dart';
import '../widgets/app_scaffold.dart';
import 'package:campingneretva_mobile/services/parcel_accommodation_service.dart';
import 'package:campingneretva_mobile/services/parcel_type_service.dart';
import 'package:campingneretva_mobile/models/parcel_accommodation_model.dart';
import 'package:campingneretva_mobile/models/parcel_type_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campingneretva_mobile/widgets/parcel_details_dialog.dart';

class ParcelsPage extends StatefulWidget {
  const ParcelsPage({super.key});

  @override
  State<ParcelsPage> createState() => _ParcelsPageState();
}

class _ParcelsPageState extends State<ParcelsPage> {
  final _accommodationService = ParcelAccommodationService();
  final _typeService = ParcelTypeService();
  List<Parcel> parcels = [];
  List<Parcel> recommendedParcels = [];
  List<ParcelAccommodation> _accommodations = [];
  List<ParcelType> _types = [];

  ParcelAccommodation? _selectedAccommodation;
  ParcelType? _selectedType;
  bool isLoading = true;

  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool? _shade;
  bool? _electricity;
  int _currentPage = 0;
  final int _pageSize = 6;

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
        page: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        parcels = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading parcels: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadRecommendedParcels() async {
    try {
      final data = await ParcelService.getRecommendedParcels();
      setState(() {
        recommendedParcels = data;
      });
    } catch (e) {
      debugPrint("Error loading recommended parcels: $e");
    }
  }

  List<Parcel> _getDisplayedParcels() {
    final recommendedIds = recommendedParcels.map((p) => p.id).toSet();
    final recommendedInPage =
        parcels.where((p) => recommendedIds.contains(p.id)).toList();
    final nonRecommendedInPage =
        parcels.where((p) => !recommendedIds.contains(p.id)).toList();

    return [...recommendedInPage, ...nonRecommendedInPage];
  }

  @override
  void initState() {
    super.initState();
    _fetchFilters();
    _loadParcels();
    _loadRecommendedParcels();
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
        _currentPage = 0;
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

  void _clearFilters() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _shade = null;
      _electricity = null;
      _selectedAccommodation = null;
      _selectedType = null;
      _currentPage = 0;
    });
    _loadParcels();
  }

  @override
  Widget build(BuildContext context) {
    final displayedParcels = _getDisplayedParcels();

    return AppScaffold(
      title: 'Parcels',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _dateFrom != null && _dateTo != null
                              ? '${DateFormat('dd.MM').format(_dateFrom!)} - ${DateFormat('dd.MM').format(_dateTo!)}'
                              : "Pick date range",
                        ),
                        onPressed: _selectDateRange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text("Remove Filters"),
                      onPressed: _clearFilters,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
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
                          setState(() {
                            _selectedAccommodation = value;
                            _currentPage = 0;
                          });
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
                    const SizedBox(width: 10),
                    Expanded(
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
                          setState(() {
                            _selectedType = value;
                            _currentPage = 0;
                          });
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
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      FilterChip(
                        label: const Text("Shade"),
                        selected: _shade == true,
                        onSelected: (selected) {
                          setState(() {
                            _shade = selected ? true : null;
                            _currentPage = 0;
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
                            _currentPage = 0;
                          });
                          _loadParcels();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child:
                          displayedParcels.isEmpty
                              ? const Center(child: Text('No parcels found.'))
                              : GridView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: displayedParcels.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.9,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                itemBuilder: (context, index) {
                                  final parcel = displayedParcels[index];
                                  final isRecommended = recommendedParcels.any(
                                    (rp) => rp.id == parcel.id,
                                  );
                                  final imageUrl =
                                      parcel.imageUrl != null &&
                                              parcel.imageUrl!.startsWith('/')
                                          ? "${dotenv.env['API_URL']!}${parcel.imageUrl}"
                                          : parcel.imageUrl ?? '';

                                  return InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => ParcelDetailsDialog(
                                              parcel: parcel,
                                            ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side:
                                            isRecommended
                                                ? const BorderSide(
                                                  color: Colors.green,
                                                  width: 2,
                                                )
                                                : BorderSide.none,
                                      ),
                                      child: Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          16,
                                                        ),
                                                      ),
                                                  child:
                                                      imageUrl.isNotEmpty
                                                          ? Image.network(
                                                            imageUrl,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (
                                                                  _,
                                                                  __,
                                                                  ___,
                                                                ) => const Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                ),
                                                          )
                                                          : const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                          ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Parcel #${parcel.number}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (isRecommended)
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                color: Colors.green,
                                                child: const Text(
                                                  "Recommended",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
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
                          ElevatedButton(
                            onPressed:
                                _currentPage > 0
                                    ? () {
                                      setState(() {
                                        _currentPage--;
                                        _loadParcels();
                                      });
                                    }
                                    : null,
                            child: const Text('Previous'),
                          ),
                          Text('Page ${_currentPage + 1}'),
                          ElevatedButton(
                            onPressed:
                                parcels.length == _pageSize
                                    ? () {
                                      setState(() {
                                        _currentPage++;
                                        _loadParcels();
                                      });
                                    }
                                    : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
