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
import '../widgets/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  late Future<List<Parcel>> _parcelsFuture;
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

  int _currentPage = 0;
  final int _pageSize = 4;
  int _totalItems = 0;
  List<Parcel> _allParcels = [];
  List<Parcel> _filteredParcels = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    parcelTypes = await ParcelTypeService.fetchAll();
    accommodations = await ParcelAccommodationService.fetchAll();
    _fetchParcels();
    setState(() => loading = false);
  }

  void _fetchParcels() {
    setState(() {
      _parcelsFuture = ParcelService.fetchAll(
        shade: shade,
        electricity: electricity,
        accommodation: selectedAccommodation?.name,
        type: selectedType?.name,
        page: 0,
        pageSize: 10000,
      );
    });
  }

  Future<void> _loadParcels() async {
    if (startDate != null && endDate != null) {
      final unavailableIds = await ParcelService.fetchUnavailableParcelIds(
        startDate!,
        endDate!,
      );

      for (var parcel in _allParcels) {
        parcel.isAvailable = !unavailableIds.contains(parcel.id);
      }
    }

    setState(() {});
  }

  List<Parcel> _applyFilters(List<Parcel> parcels) {
    var filtered =
        parcels.where((p) {
          final numberMatch = p.number.toString().contains(_searchQuery);
          return numberMatch;
        }).toList();
    _filteredParcels = filtered;
    _totalItems = filtered.length;
    return filtered;
  }

  Future<String?> _promptInput(String label) async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(label),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Unesite naziv"),
            ),
            actions: [
              TextButton(
                style: AppTheme.greenTextButtonStyle,
                onPressed: () => Navigator.pop(context),
                child: const Text("Odustani"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text("Dodaj"),
              ),
            ],
          ),
    );
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

    ParcelType? typeValue =
        parcelTypes.isNotEmpty
            ? (isEditing
                ? parcelTypes.firstWhere(
                  (t) => t.name == parcel?.parcelType.name,
                  orElse: () => parcelTypes.first,
                )
                : parcelTypes.first)
            : null;

    ParcelAccommodation? accValue =
        accommodations.isNotEmpty
            ? (isEditing
                ? accommodations.firstWhere(
                  (a) => a.name == parcel?.parcelAccommodation.name,
                  orElse: () => accommodations.first,
                )
                : accommodations.first)
            : null;

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
                              parcelTypes
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) => setState(() => typeValue = value),
                          style: const TextStyle(color: Colors.black87),
                          dropdownColor: Colors.white,
                          underline: Container(height: 1, color: Colors.green),
                        ),
                        DropdownButton<ParcelAccommodation>(
                          value: accValue,
                          isExpanded: true,
                          hint: const Text("Smještaj"),
                          items:
                              accommodations
                                  .map(
                                    (a) => DropdownMenuItem(
                                      value: a,
                                      child: Text(a.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) => setState(() => accValue = value),
                          style: const TextStyle(color: Colors.black87),
                          dropdownColor: Colors.white,
                          underline: Container(height: 1, color: Colors.green),
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
                              "${dotenv.env['API_URL']!}$imageUrl",
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
                      style: AppTheme.greenTextButtonStyle,
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
                          parcelAccommodation: accValue!,
                          parcelType: typeValue!,
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
                          _fetchParcels();
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
                    style: AppTheme.greenTextButtonStyle,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Odustani'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Obriši'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmed) {
      await ParcelService.delete(parcel.id);
      _fetchParcels();
    }
  }

  Future<void> _showDetailsDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Detalji o smještajima i tipovima parcela"),
              content: SizedBox(
                width: 600,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tipovi parcela",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...parcelTypes.map(
                            (t) => ListTile(
                              title: Text(t.name),
                              trailing: IconButton(
                                style: AppTheme.greenIconButtonStyle,
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await ParcelTypeService.delete(t.id);
                                  parcelTypes =
                                      await ParcelTypeService.fetchAll();
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          TextButton.icon(
                            style: AppTheme.greenTextButtonStyle,
                            onPressed: () async {
                              final name = await _promptInput(
                                "Novi tip parcele",
                              );
                              if (name != null && name.isNotEmpty) {
                                await ParcelTypeService.create(
                                  ParcelType(id: 0, name: name),
                                );
                                parcelTypes =
                                    await ParcelTypeService.fetchAll();
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Dodaj tip"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Smještaji",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...accommodations.map(
                            (a) => ListTile(
                              title: Text(a.name),
                              trailing: IconButton(
                                style: AppTheme.greenIconButtonStyle,
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await ParcelAccommodationService.delete(a.id);
                                  accommodations =
                                      await ParcelAccommodationService.fetchAll();
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          TextButton.icon(
                            style: AppTheme.greenTextButtonStyle,
                            onPressed: () async {
                              final name = await _promptInput("Novi smještaj");
                              if (name != null && name.isNotEmpty) {
                                await ParcelAccommodationService.create(
                                  ParcelAccommodation(id: 0, name: name),
                                );
                                accommodations =
                                    await ParcelAccommodationService.fetchAll();
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Dodaj smještaj"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  style: AppTheme.greenTextButtonStyle,
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Zatvori"),
                ),
              ],
            );
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
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
                              '🍀 Upravljanje parcelama',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            style: AppTheme.greenIconButtonStyle,
                            icon: const Icon(Icons.add),
                            onPressed: () => _showParcelDialog(),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.info_outline),
                            label: const Text("Pregled detalja"),
                            onPressed: _showDetailsDialog,
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
                                              style:
                                                  AppTheme.greenIconButtonStyle,
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
                                      parcelTypes
                                          .map(
                                            (t) => DropdownMenuItem(
                                              value: t,
                                              child: Text(t.name),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setState(() => selectedType = value);
                                    _fetchParcels();
                                  },
                                  style: const TextStyle(color: Colors.black87),
                                  dropdownColor: Colors.white,
                                  underline: Container(
                                    height: 1,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButton<ParcelAccommodation>(
                                  value: selectedAccommodation,
                                  isExpanded: true,
                                  hint: const Text("Smještaj"),
                                  items:
                                      accommodations
                                          .map(
                                            (a) => DropdownMenuItem(
                                              value: a,
                                              child: Text(a.name),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setState(
                                      () => selectedAccommodation = value,
                                    );
                                    _fetchParcels();
                                  },
                                  style: const TextStyle(color: Colors.black87),
                                  dropdownColor: Colors.white,
                                  underline: Container(
                                    height: 1,
                                    color: Colors.green,
                                  ),
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
                                  _fetchParcels();
                                },
                              ),
                              const Text('Sjena'),
                              const SizedBox(width: 20),
                              Checkbox(
                                value: electricity ?? false,
                                onChanged: (v) {
                                  setState(() => electricity = v);
                                  _fetchParcels();
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
                                      _fetchParcels();
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
                                    _searchQuery = '';
                                    _searchController.clear();
                                    _currentPage = 0;
                                  });
                                  _fetchParcels();
                                },
                                child: const Text("Resetuj filtere"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: FutureBuilder<List<Parcel>>(
                        future: _parcelsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Nije pronađena ni jedna parcela.'),
                            );
                          }

                          _allParcels = snapshot.data!;
                          _loadParcels();
                          final filteredParcels = _applyFilters(_allParcels);

                          final startIndex = _currentPage * _pageSize;
                          final endIndex =
                              startIndex + _pageSize > _totalItems
                                  ? _totalItems
                                  : startIndex + _pageSize;
                          final paginatedParcels = filteredParcels.sublist(
                            startIndex,
                            endIndex,
                          );

                          return Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: paginatedParcels.length,
                                  itemBuilder: (_, index) {
                                    final parcel = paginatedParcels[index];
                                    final imageUrl =
                                        "${dotenv.env['API_URL']!}${parcel.imageUrl}";

                                    return Card(
                                      color:
                                          parcel.isAvailable
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.surface
                                              : Colors.red[50],
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: ListTile(
                                        leading: Image.network(
                                          imageUrl,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              ),
                                        ),
                                        title: Text(
                                          "Parcela #${parcel.number}",
                                        ),
                                        subtitle: Text(
                                          "${parcel.parcelType.name} - ${parcel.parcelAccommodation.name}",
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              style:
                                                  AppTheme.greenIconButtonStyle,
                                              icon: const Icon(Icons.edit),
                                              onPressed:
                                                  () => _showParcelDialog(
                                                    parcel: parcel,
                                                  ),
                                            ),
                                            IconButton(
                                              style:
                                                  AppTheme.greenIconButtonStyle,
                                              icon: const Icon(Icons.delete),
                                              onPressed:
                                                  () => _showConfirmDelete(
                                                    parcel,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              _buildPaginationControls(),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
    );
  }
}
