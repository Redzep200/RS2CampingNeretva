import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';
import '../services/image_service.dart';
import '../widgets/navbar.dart';
import '../models/facility_model.dart';
import '../services/facility_service.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<Activity> _activities = [];
  List<Activity> _filteredActivities = [];
  String _searchQuery = '';
  DateTime? _selectedDate;
  int _sortMode = 0;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final activities = await ActivityService.fetchAll();
    setState(() {
      _activities = activities;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Activity> filtered = [..._activities];

    if (_selectedDate != null) {
      filtered =
          filtered
              .where(
                (a) =>
                    a.date.year == _selectedDate!.year &&
                    a.date.month == _selectedDate!.month &&
                    a.date.day == _selectedDate!.day,
              )
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (a) =>
                    a.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
    }

    if (_sortMode == 1) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortMode == 2) {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    setState(() {
      _filteredActivities = filtered;
    });
  }

  Future<void> _deleteActivity(int id) async {
    await ActivityService.delete(id);
    _loadActivities();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _showActivityDialog({Activity? activity}) async {
    final isEditing = activity != null;
    final facilities = await FacilityService.fetchAll();
    Facility? selectedFacility = activity?.facility;
    final nameController = TextEditingController(text: activity?.name ?? '');
    final descController = TextEditingController(
      text: activity?.description ?? '',
    );
    final priceController = TextEditingController(
      text: isEditing ? activity!.price.toString() : '',
    );
    DateTime selectedDate = activity?.date ?? DateTime.now();
    String? uploadedImageUrl = activity?.imageUrl;
    int? uploadedImageId = activity?.imageId;

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(isEditing ? 'Edit Activity' : 'Add Activity'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Price (€)',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Date:'),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              child: Text(
                                selectedDate.toLocal().toString().split(' ')[0],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Facility>(
                          value: selectedFacility,
                          decoration: const InputDecoration(
                            labelText: 'Facility',
                          ),
                          isExpanded: true,
                          items:
                              facilities.map((f) {
                                return DropdownMenuItem(
                                  value: f,
                                  child: Text(f.facilityType),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedFacility = val;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
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
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Image'),
                        ),
                        if (uploadedImageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth:
                                      300, // set a maximum width instead of infinity
                                ),
                                child: Image.network(
                                  'http://localhost:5205$uploadedImageUrl',
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                ),
                              ),
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
                        final name = nameController.text.trim();
                        final desc = descController.text.trim();
                        final price = double.tryParse(
                          priceController.text.trim(),
                        );

                        if (name.isEmpty || desc.isEmpty || price == null) {
                          _showError('All fields must be filled correctly.');
                          return;
                        }
                        if (selectedDate.isBefore(DateTime.now())) {
                          _showError('Date cannot be in the past.');
                          return;
                        }

                        final newActivity = Activity(
                          id: isEditing ? activity!.id : 0,
                          name: name,
                          description: desc,
                          date: selectedDate,
                          price: price,
                          imageUrl: uploadedImageUrl ?? '',
                          imageId: uploadedImageId,
                          facility: selectedFacility,
                        );

                        try {
                          if (isEditing) {
                            await ActivityService.update(newActivity);
                          } else {
                            await ActivityService.create(newActivity);
                          }
                          Navigator.pop(context);
                          _loadActivities();
                        } catch (_) {
                          _showError('Failed to save activity.');
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final imageUrl = 'http://localhost:5205${activity.imageUrl}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "📅 ${activity.date.toLocal().toString().split(' ')[0]}",
                    ),
                    Text("💰 €${activity.price.toStringAsFixed(2)}"),
                    if (activity.facility != null)
                      Text("🏕 ${activity.facility!.facilityType}"),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showActivityDialog(activity: activity),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Delete Activity'),
                              content: const Text(
                                'Are you sure you want to delete this activity?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await _deleteActivity(activity.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search & Add
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search by name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    tooltip: 'Add Activity',
                    onPressed: () => _showActivityDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sorting & Date Filter
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _sortMode == 1
                          ? Icons.arrow_upward
                          : _sortMode == 2
                          ? Icons.arrow_downward
                          : Icons.swap_vert,
                      color: Colors.blueGrey,
                    ),
                    tooltip: 'Sort by price',
                    onPressed: () {
                      setState(() {
                        _sortMode = (_sortMode + 1) % 3;
                        _applyFilters();
                      });
                    },
                  ),
                  Text(
                    _sortMode == 1
                        ? 'Price: Low → High'
                        : _sortMode == 2
                        ? 'Price: High → Low'
                        : 'No sorting',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.green),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _applyFilters();
                        });
                      }
                    },
                  ),
                  if (_selectedDate != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                          _applyFilters();
                        });
                      },
                      child: const Text('Clear Date'),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Activity List
              Expanded(
                child:
                    _filteredActivities.isEmpty
                        ? const Center(child: Text("No activities found."))
                        : ListView.builder(
                          itemCount: _filteredActivities.length,
                          itemBuilder: (context, index) {
                            return _buildActivityCard(
                              _filteredActivities[index],
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
