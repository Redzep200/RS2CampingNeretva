import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/parcel_model.dart';
import '../models/parcel_type_model.dart';
import '../models/parcel_accommodation_model.dart';
import '../services/parcel_service.dart';
import '../services/parcel_type_service.dart';
import '../services/parcel_accommodation_service.dart';
import '../services/image_service.dart';
import '../widgets/navbar.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});
  static const String baseUrl = "http://localhost:5205";

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  List<Parcel> parcels = [];
  List<ParcelType> parcelTypes = [];
  List<ParcelAccommodation> accommodations = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ParcelType? selectedType;
  ParcelAccommodation? selectedAccommodation;
  bool? electricity;
  bool? shade;
  DateTime? startDate;
  DateTime? endDate;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    parcelTypes = await ParcelTypeService.fetchAll();
    accommodations = await ParcelAccommodationService.fetchAll();
    await _loadParcels();
    setState(() => loading = false);
  }

  Future<void> _loadParcels() async {
    // Fetch all available parcels
    parcels = await ParcelService.fetchAll(
      shade: shade,
      electricity: electricity,
      accommodation: selectedAccommodation?.name,
      type: selectedType?.name,
    );

    // If range selected, fetch unavailable ones
    if (startDate != null && endDate != null) {
      final unavailableIds = await ParcelService.fetchUnavailableParcelIds(
        startDate!,
        endDate!,
      );

      for (var parcel in parcels) {
        parcel.isAvailable = !unavailableIds.contains(parcel.id);
      }
    }

    setState(() {});
  }

  Future<void> _showParcelDialog({Parcel? parcel}) async {
    final isEditing = parcel != null;

    final numberController = TextEditingController(
      text: parcel?.number.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: parcel?.description ?? '',
    );
    bool shadeValue = parcel?.shade ?? false;
    bool electricityValue = parcel?.electricity ?? false;
    ParcelType? typeValue = parcelTypes.firstWhere(
      (t) => t.name == parcel?.parcelType,
      orElse: () => parcelTypes.first,
    );
    ParcelAccommodation? accValue = accommodations.firstWhere(
      (a) => a.name == parcel?.parcelAccommodation,
      orElse: () => accommodations.first,
    );
    String? imageUrl = parcel?.imageUrl;
    int? imageId = parcel?.imageId;

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(isEditing ? 'Uredi parcelu' : 'Dodaj parcelu'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: numberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Broj parcele',
                          ),
                        ),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(labelText: 'Opis'),
                          maxLines: 3,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: shadeValue,
                              onChanged: (v) => setState(() => shadeValue = v!),
                            ),
                            const Text('Sjena'),
                            const SizedBox(width: 20),
                            Checkbox(
                              value: electricityValue,
                              onChanged:
                                  (v) => setState(() => electricityValue = v!),
                            ),
                            const Text('Struja'),
                          ],
                        ),
                        DropdownButton<ParcelType>(
                          value: typeValue,
                          isExpanded: true,
                          hint: const Text("Tip parcele"),
                          items:
                              parcelTypes.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(() => typeValue = value),
                        ),
                        DropdownButton<ParcelAccommodation>(
                          value: accValue,
                          isExpanded: true,
                          hint: const Text("Smještaj"),
                          items:
                              accommodations.map((a) {
                                return DropdownMenuItem(
                                  value: a,
                                  child: Text(a.name),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(() => accValue = value),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );
                            if (result != null &&
                                result.files.single.path != null) {
                              final file = File(result.files.single.path!);
                              final imageModel = await ImageService.upload(
                                file,
                              );
                              setState(() {
                                imageUrl = imageModel.path;
                                imageId = imageModel.imageId;
                              });
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Upload sliku"),
                        ),
                        if (imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(
                              "${ParcelPage.baseUrl}$imageUrl",
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Odustani'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final number = int.tryParse(
                          numberController.text.trim(),
                        );
                        if (number == null ||
                            typeValue == null ||
                            accValue == null) {
                          _showError('Molimo unesite sve obavezne podatke.');
                          return;
                        }

                        final newParcel = Parcel(
                          id: isEditing ? parcel!.id : 0,
                          number: number,
                          shade: shadeValue,
                          electricity: electricityValue,
                          description: descriptionController.text.trim(),
                          isAvailable: true,
                          parcelAccommodation: accValue!.name,
                          parcelType: typeValue!.name,
                          imageUrl: imageUrl ?? '',
                          imageId: imageId,
                        );

                        try {
                          if (isEditing) {
                            await ParcelService.update(newParcel);
                          } else {
                            await ParcelService.create(newParcel);
                          }
                          Navigator.pop(context);
                          _loadParcels();
                        } catch (_) {
                          _showError('Greška pri spašavanju parcele.');
                        }
                      },
                      child: const Text('Spasi'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showConfirmDelete(Parcel parcel) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Potvrdi brisanje'),
                content: Text(
                  'Da li ste sigurni da želite obrisati parcelu #${parcel.number}?',
                ),
                actions: [
                  TextButton(
                    child: const Text('Odustani'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Obriši'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmed) {
      await ParcelService.delete(parcel.id);
      _loadParcels();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredParcels =
        parcels.where((p) {
          return p.number.toString().contains(_searchQuery);
        }).toList();

    return Scaffold(
      appBar: const CustomNavbar(),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '📦 Upravljanje parcelama',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => _showParcelDialog(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    labelText: 'Broj parcele',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon:
                                        _searchQuery.isNotEmpty
                                            ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(
                                                  () => _searchQuery = '',
                                                );
                                              },
                                            )
                                            : null,
                                  ),
                                  onChanged:
                                      (value) =>
                                          setState(() => _searchQuery = value),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<ParcelType>(
                                  value: selectedType,
                                  isExpanded: true,
                                  hint: const Text("Tip parcele"),
                                  items:
                                      parcelTypes.map((t) {
                                        return DropdownMenuItem(
                                          value: t,
                                          child: Text(t.name),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() => selectedType = value);
                                    _loadParcels();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButton<ParcelAccommodation>(
                                  value: selectedAccommodation,
                                  isExpanded: true,
                                  hint: const Text("Smještaj"),
                                  items:
                                      accommodations.map((a) {
                                        return DropdownMenuItem(
                                          value: a,
                                          child: Text(a.name),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(
                                      () => selectedAccommodation = value,
                                    );
                                    _loadParcels();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: shade ?? false,
                                onChanged: (v) {
                                  setState(() => shade = v);
                                  _loadParcels();
                                },
                              ),
                              const Text('Sjena'),
                              const SizedBox(width: 20),
                              Checkbox(
                                value: electricity ?? false,
                                onChanged: (v) {
                                  setState(() => electricity = v);
                                  _loadParcels();
                                },
                              ),
                              const Text('Struja'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final pickedStart = await showDatePicker(
                                    context: context,
                                    initialDate: startDate ?? DateTime.now(),
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365 * 2),
                                    ),
                                  );

                                  if (pickedStart != null) {
                                    final pickedEnd = await showDatePicker(
                                      context: context,
                                      initialDate: pickedStart,
                                      firstDate: pickedStart,
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365 * 2),
                                      ),
                                    );

                                    if (pickedEnd != null) {
                                      setState(() {
                                        startDate = pickedStart;
                                        endDate = pickedEnd;
                                      });

                                      _loadParcels();
                                    }
                                  }
                                },
                                icon: const Icon(Icons.date_range),
                                label: Text(
                                  startDate == null || endDate == null
                                      ? "Odaberi raspon datuma"
                                      : "${DateFormat('dd.MM.yyyy').format(startDate!)} - ${DateFormat('dd.MM.yyyy').format(endDate!)}",
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedType = null;
                                    selectedAccommodation = null;
                                    electricity = null;
                                    shade = null;
                                    startDate = null;
                                    endDate = null;
                                  });
                                  _loadParcels();
                                },
                                child: const Text("Resetuj filtere"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredParcels.length,
                      itemBuilder: (_, index) {
                        final parcel = filteredParcels[index];
                        final imageUrl =
                            "${ParcelPage.baseUrl}${parcel.imageUrl}";

                        return Card(
                          color:
                              parcel.isAvailable
                                  ? Colors.green[50]
                                  : Colors.red[50],
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 40),
                            ),
                            title: Text("Parcela #${parcel.number}"),
                            subtitle: Text(
                              "${parcel.parcelType} - ${parcel.parcelAccommodation}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                  onPressed:
                                      () => _showParcelDialog(parcel: parcel),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _showConfirmDelete(parcel),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
    );
  }
}
