import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/rentable_item_model.dart';
import '../services/rentable_item_service.dart';
import '../services/image_service.dart';
import '../widgets/navbar.dart';
import '../widgets/app_theme.dart';

class RentableItemsPage extends StatefulWidget {
  const RentableItemsPage({super.key});
  static const String baseUrl = "http://localhost:5205";

  @override
  State<RentableItemsPage> createState() => _RentableItemsPageState();
}

class _RentableItemsPageState extends State<RentableItemsPage> {
  bool loading = true;
  List<RentableItem> items = [];
  List<RentableItem> filteredItems = [];
  String sortMode = 'none';
  String nameFilter = '';
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => loading = true);
    try {
      if (fromDate != null && toDate != null) {
        print(
          'Loading available items from ${DateFormat('yyyy-MM-dd').format(fromDate!)} to ${DateFormat('yyyy-MM-dd').format(toDate!)}',
        );
        items = await RentableItemService.getAvailable(
          DateFormat('yyyy-MM-dd').format(fromDate!),
          DateFormat('yyyy-MM-dd').format(toDate!),
        );
      } else {
        print('Loading all items');
        items = await RentableItemService.fetchAll();
      }
      _applyFilters();
    } catch (e) {
      print('Error loading items: $e');
      _showError('Greška pri učitavanju stavki: $e');
    }
    setState(() => loading = false);
  }

  void _applyFilters() {
    List<RentableItem> filtered = [...items];

    if (nameFilter.isNotEmpty) {
      filtered =
          filtered
              .where(
                (item) =>
                    item.name.toLowerCase().contains(nameFilter.toLowerCase()),
              )
              .toList();
    }

    switch (sortMode) {
      case 'asc':
        filtered.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'desc':
        filtered.sort((a, b) => b.pricePerDay.compareTo(b.pricePerDay));
        break;
      default:
        break;
    }

    setState(() => filteredItems = filtered);
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
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Otkaži'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Obriši'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _showItemDialog({RentableItem? item}) async {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(
      text: item?.pricePerDay.toString() ?? '',
    );
    final quantityController = TextEditingController(
      text: item?.totalQuantity.toString() ?? '',
    );

    String? uploadedImageUrl = item?.imageUrl;
    int? uploadedImageId = item?.imageId;

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(isEditing ? 'Uredi stavku' : 'Dodaj stavku'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Naziv'),
                        ),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(labelText: 'Opis'),
                          maxLines: 3,
                        ),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cijena po danu',
                          ),
                        ),
                        TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Ukupna količina',
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
                                uploadedImageUrl =
                                    imageModel.path.startsWith('/')
                                        ? imageModel.path
                                        : '/${imageModel.path}';
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "${RentableItemsPage.baseUrl}$uploadedImageUrl",
                                width: 150,
                                height: 150,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                              ),
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
                        final name = nameController.text.trim();
                        final desc = descController.text.trim();
                        final price = double.tryParse(
                          priceController.text.trim(),
                        );
                        final quantity = int.tryParse(
                          quantityController.text.trim(),
                        );

                        if (name.isEmpty ||
                            desc.isEmpty ||
                            price == null ||
                            quantity == null) {
                          _showError('Molimo unesite sve podatke ispravno.');
                          return;
                        }

                        if (!isEditing &&
                            (uploadedImageUrl == null ||
                                uploadedImageId == null)) {
                          _showError('Molimo dodajte sliku.');
                          return;
                        }

                        final newItem = RentableItem(
                          id: isEditing ? item!.id : 0,
                          name: name,
                          description: desc,
                          pricePerDay: price,
                          imageUrl: uploadedImageUrl ?? '',
                          imageId: uploadedImageId,
                          totalQuantity: quantity,
                        );

                        try {
                          if (isEditing) {
                            await RentableItemService.update(newItem);
                          } else {
                            await RentableItemService.create(newItem);
                          }
                          Navigator.pop(context);
                          _loadItems();
                        } catch (e) {
                          _showError('Greška pri spašavanju stavke.');
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

  Widget _buildItemImage(String? imageUrl) {
    final fullUrl =
        (imageUrl != null && imageUrl.isNotEmpty)
            ? (imageUrl.startsWith('http')
                ? imageUrl
                : "${RentableItemsPage.baseUrl}$imageUrl")
            : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child:
          fullUrl != null
              ? Image.network(
                fullUrl,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
              )
              : Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40),
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '📦 Rentabilne stavke',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                style: AppTheme.greenIconButtonStyle,
                                icon: const Icon(Icons.add),
                                onPressed: () => _showItemDialog(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Filtriraj po nazivu...',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              nameFilter = value;
                              _applyFilters();
                            },
                          ),
                          Row(
                            children: [
                              DropdownButton<String>(
                                value: sortMode,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'none',
                                    child: Text('Bez sortiranja'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'asc',
                                    child: Text('Cijena: Najniža'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'desc',
                                    child: Text('Cijena: Najviša'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    sortMode = value!;
                                    _applyFilters();
                                  });
                                },
                                style: const TextStyle(color: Colors.black87),
                                dropdownColor: Colors.white,
                                underline: Container(
                                  height: 1,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton.icon(
                                    style: AppTheme.greenTextButtonStyle,
                                    icon: const Icon(Icons.date_range),
                                    label: Text(
                                      fromDate != null && toDate != null
                                          ? "Datum: ${DateFormat('dd.MM.yyyy').format(fromDate!)} - ${DateFormat('dd.MM.yyyy').format(toDate!)}"
                                          : "Izaberi datum",
                                    ),
                                    onPressed: () async {
                                      final picked = await showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                        initialDateRange:
                                            fromDate != null && toDate != null
                                                ? DateTimeRange(
                                                  start: fromDate!,
                                                  end: toDate!,
                                                )
                                                : null,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          fromDate = picked.start;
                                          toDate = picked.end;
                                        });
                                        _loadItems();
                                      }
                                    },
                                  ),
                                  if (fromDate != null && toDate != null)
                                    TextButton(
                                      style: AppTheme.greenTextButtonStyle,
                                      onPressed: () {
                                        setState(() {
                                          fromDate = null;
                                          toDate = null;
                                        });
                                        _loadItems();
                                      },
                                      child: const Text("Obriši filter"),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredItems.length,
                      itemBuilder: (_, index) {
                        final item = filteredItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: _buildItemImage(item.imageUrl),
                            title: Text(item.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.description),
                                const SizedBox(height: 4),
                                Text(
                                  "Cijena: ${item.pricePerDay.toStringAsFixed(2)} KM",
                                ),
                                Text("Ukupno: ${item.totalQuantity}"),
                                if (item.availableQuantity != null)
                                  Text("Dostupno: ${item.availableQuantity}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  style: AppTheme.greenIconButtonStyle,
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showItemDialog(item: item),
                                ),
                                IconButton(
                                  style: AppTheme.greenIconButtonStyle,
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final confirm =
                                        await _showConfirmDeleteDialog();
                                    if (confirm) {
                                      await RentableItemService.delete(item.id);
                                      _loadItems();
                                    }
                                  },
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
