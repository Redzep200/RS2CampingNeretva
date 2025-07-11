import 'dart:io';
import 'package:campingneretva_desktop/models/accommodation_model.dart';
import 'package:campingneretva_desktop/models/person_model.dart';
import 'package:campingneretva_desktop/models/vehicle_model.dart';
import 'package:campingneretva_desktop/services/accommodation_service.dart';
import 'package:campingneretva_desktop/services/image_service.dart';
import 'package:campingneretva_desktop/services/person_service.dart';
import 'package:campingneretva_desktop/services/vehicle_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PricePage extends StatefulWidget {
  const PricePage({super.key});

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  bool loading = true;
  List<Accommodation> accommodations = [];
  List<PersonType> persons = [];
  List<Vehicle> vehicles = [];

  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
    _searchController.addListener(() {
      setState(() => searchQuery = _searchController.text.toLowerCase());
    });
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    accommodations = await AccommodationService.fetchAll();
    persons = await PersonService.fetchAll();
    vehicles = await VehicleService.fetchAll();
    setState(() => loading = false);
  }

  Future<bool> _showConfirmDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Potvrdi brisanje'),
                content: const Text(
                  'Da li ste sigurni da želite obrisati stavku?',
                ),
                actions: [
                  TextButton(
                    style: AppTheme.greenTextButtonStyle,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Izlaz'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Obriši'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _showItemDialog<T>({
    required String title,
    T? item,
    required Future<void> Function(T) onSave,
    required T Function(String, double, String, int?, int) createItem,
  }) async {
    final isEditing = item != null;
    final typeController = TextEditingController(
      text: isEditing ? (item as dynamic).type : '',
    );
    final priceController = TextEditingController(
      text: isEditing ? (item as dynamic).price.toString() : '',
    );

    String? uploadedImageUrl = isEditing ? (item as dynamic).imageUrl : null;
    int? uploadedImageId = isEditing ? (item as dynamic).imageId : null;

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    isEditing ? 'Uredi stavku $title' : 'Nova stavka $title',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: typeController,
                          decoration: const InputDecoration(labelText: 'Vrsta'),
                        ),
                        TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Cijena (€)',
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                uploadedImageUrl = imageModel.path;
                                uploadedImageId = imageModel.imageId;
                              });
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Upload Image"),
                        ),
                        if (uploadedImageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(
                              "${dotenv.env['API_URL']!}$uploadedImageUrl",
                              width: 100,
                              height: 100,
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
                      child: const Text('Izlaz'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final type = typeController.text.trim();
                        final price = double.tryParse(
                          priceController.text.trim(),
                        );
                        if (type.isNotEmpty &&
                            price != null &&
                            uploadedImageUrl != null) {
                          final newItem = createItem(
                            type,
                            price,
                            uploadedImageUrl!,
                            uploadedImageId,
                            isEditing ? (item as dynamic).id : 0,
                          );

                          try {
                            await onSave(newItem);
                            Navigator.pop(context);
                            _loadAll();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Greška pri spremanju: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Spasi'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildSection<T>({
    required String title,
    required List<T> items,
    required Future<void> Function(T item) onDelete,
    required Future<void> Function(T item) onSave,
    required T Function(String, double, String, int?, int) createItem,
  }) {
    final filteredItems =
        items.where((item) {
          final type = (item as dynamic).type.toString().toLowerCase();
          return type.contains(searchQuery);
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                style: AppTheme.greenIconButtonStyle,
                icon: const Icon(Icons.add),
                onPressed:
                    () => _showItemDialog<T>(
                      title: title,
                      onSave: onSave,
                      createItem: createItem,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredItems.length,
          itemBuilder: (_, index) {
            final item = filteredItems[index] as dynamic;
            final imageUrl = "${dotenv.env['API_URL']!}${item.imageUrl}";

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                ),
                title: Text('${item.type}'),
                subtitle: Text('€${item.price.toStringAsFixed(2)} / noć'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      style: AppTheme.greenIconButtonStyle,
                      icon: const Icon(Icons.edit),
                      onPressed:
                          () => _showItemDialog<T>(
                            title: title,
                            item: item,
                            onSave: onSave,
                            createItem: createItem,
                          ),
                    ),
                    IconButton(
                      style: AppTheme.greenIconButtonStyle,
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await _showConfirmDeleteDialog();
                        if (confirm) {
                          await onDelete(item);
                          _loadAll();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Pretraga po nazivu...',
                        ),
                      ),
                    ),
                    _buildSection<Vehicle>(
                      title: '🚗 Vozila',
                      items: vehicles,
                      onDelete: (v) => VehicleService.delete(v.id),
                      onSave: (v) async {
                        if (v.id == 0) {
                          await VehicleService.create(v);
                        } else {
                          await VehicleService.update(v);
                        }
                      },
                      createItem:
                          (type, price, imageUrl, imageId, id) => Vehicle(
                            id: id,
                            type: type,
                            price: price,
                            imageUrl: imageUrl,
                            imageId: imageId,
                          ),
                    ),
                    _buildSection<PersonType>(
                      title: '🧝 Osobe',
                      items: persons,
                      onDelete: (p) => PersonService.delete(p.id),
                      onSave: (p) async {
                        if (p.id == 0) {
                          await PersonService.create(p);
                        } else {
                          await PersonService.update(p);
                        }
                      },
                      createItem:
                          (type, price, imageUrl, imageId, id) => PersonType(
                            id: id,
                            type: type,
                            price: price,
                            imageUrl: imageUrl,
                            imageId: imageId,
                          ),
                    ),
                    _buildSection<Accommodation>(
                      title: '⛺ Smještaji',
                      items: accommodations,
                      onDelete: (a) => AccommodationService.delete(a.id),
                      onSave: (a) async {
                        if (a.id == 0) {
                          await AccommodationService.create(a);
                        } else {
                          await AccommodationService.update(a);
                        }
                      },
                      createItem:
                          (type, price, imageUrl, imageId, id) => Accommodation(
                            id: id,
                            type: type,
                            price: price,
                            imageUrl: imageUrl,
                            imageId: imageId,
                          ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
    );
  }
}
