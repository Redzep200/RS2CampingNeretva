import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/facility_model.dart';
import '../services/facility_service.dart';
import '../services/image_service.dart';
import '../widgets/navbar.dart';

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
                title: const Text('Confirm Deletion'),
                content: const Text(
                  'Are you sure you want to delete this facility?',
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                    onPressed: () => Navigator.of(context).pop(true),
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
                  title: Text(isEditing ? 'Edit Facility' : 'Add Facility'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: typeController,
                          decoration: const InputDecoration(
                            labelText: 'Facility Type',
                          ),
                        ),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
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
                          _showError('Facility type is required.');
                          return;
                        }
                        if (wordCount < 20) {
                          _showError(
                            'Description must contain at least 20 words.',
                          );
                          return;
                        }
                        if (!isEditing &&
                            (uploadedImageUrl == null ||
                                uploadedImageId == null)) {
                          _showError('Please upload an image.');
                          return;
                        }

                        final newFacility = Facility(
                          id: isEditing ? facility!.id : 0,
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
                          _showError('Error saving facility.');
                        }
                      },
                      child: const Text('Save'),
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
                            icon: const Icon(Icons.add, color: Colors.green),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                  onPressed:
                                      () => _showFacilityDialog(
                                        facility: facility,
                                      ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
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
