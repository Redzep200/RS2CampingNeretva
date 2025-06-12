import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/facility_model.dart';
import '../services/facility_service.dart';
import '../services/image_service.dart';
import '../widgets/navbar.dart';
import '../widgets/app_theme.dart';

class FacilityPage extends StatefulWidget {
  const FacilityPage({super.key});
  static const String baseUrl = "http://localhost:5205";

  @override
  State<FacilityPage> createState() => _FacilityPageState();
}

class _FacilityPageState extends State<FacilityPage> {
  bool loading = true;
  List<Facility> facilities = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() => loading = true);
    facilities = await FacilityService.fetchAll();
    setState(() => loading = false);
  }

  Future<bool> _showConfirmDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Potvrdi brisanje'),
                content: const Text(
                  'Da li ste sigurni da želite obrisati sadržaj?',
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

  Future<void> _showFacilityDialog({Facility? facility}) async {
    final isEditing = facility != null;
    final typeController = TextEditingController(
      text: facility?.facilityType ?? '',
    );
    final descController = TextEditingController(
      text: facility?.description ?? '',
    );

    String? uploadedImageUrl = facility?.imageUrl;
    int? uploadedImageId = facility?.imageId;

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(isEditing ? 'Uredi sadržaj' : 'Dodaj sadržaj'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: typeController,
                          decoration: const InputDecoration(
                            labelText: 'Vrsta sadržaja',
                          ),
                        ),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(labelText: 'Opis'),
                          maxLines: 5,
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
                              "${FacilityPage.baseUrl}$uploadedImageUrl",
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
                      child: const Text('Izlaz'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final type = typeController.text.trim();
                        final desc = descController.text.trim();
                        final wordCount =
                            desc
                                .split(RegExp(r'\s+'))
                                .where((w) => w.isNotEmpty)
                                .length;

                        if (type.isEmpty) {
                          _showError('Potreban unos vrste sadržaja.');
                          return;
                        }
                        if (wordCount < 10) {
                          _showError(
                            'Opis mora da sadrži minimalno 10 riječi.',
                          );
                          return;
                        }
                        if (!isEditing &&
                            (uploadedImageUrl == null ||
                                uploadedImageId == null)) {
                          _showError('Molim vas ubacite sliku.');
                          return;
                        }

                        final newFacility = Facility(
                          id: isEditing ? facility.id : 0,
                          facilityType: type,
                          description: desc,
                          imageUrl: uploadedImageUrl!,
                          imageId: uploadedImageId,
                        );

                        try {
                          if (isEditing) {
                            await FacilityService.update(newFacility);
                          } else {
                            await FacilityService.create(newFacility);
                          }
                          Navigator.pop(context);
                          _loadFacilities();
                        } catch (e) {
                          _showError('Greška pri spašavanju sadržaja.');
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

  @override
  Widget build(BuildContext context) {
    final filteredFacilities =
        facilities.where((f) {
          return f.facilityType.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
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
                              '🏕️ Sadržaji kampa',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            style: AppTheme.greenIconButtonStyle,
                            icon: const Icon(Icons.add),
                            onPressed: () => _showFacilityDialog(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Potraga po nazivu',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon:
                              _searchQuery.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                  : null,
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredFacilities.length,
                      itemBuilder: (_, index) {
                        final facility = filteredFacilities[index];
                        final imageUrl =
                            "${FacilityPage.baseUrl}${facility.imageUrl}";

                        return Card(
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
                            title: Text(facility.facilityType),
                            subtitle: Text(
                              facility.description ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  style: AppTheme.greenIconButtonStyle,
                                  icon: const Icon(Icons.edit),
                                  onPressed:
                                      () => _showFacilityDialog(
                                        facility: facility,
                                      ),
                                ),
                                IconButton(
                                  style: AppTheme.greenIconButtonStyle,
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final confirm =
                                        await _showConfirmDeleteDialog();
                                    if (confirm) {
                                      await FacilityService.delete(facility.id);
                                      _loadFacilities();
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
