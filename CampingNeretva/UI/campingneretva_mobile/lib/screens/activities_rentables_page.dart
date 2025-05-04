import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campingneretva_mobile/models/rentable_item_model.dart';
import 'package:campingneretva_mobile/models/activity_model.dart';
import '../services/rentable_item_service.dart';
import '../services/activity_service.dart';

class ActivitiesRentablesPage extends StatefulWidget {
  const ActivitiesRentablesPage({super.key});

  @override
  State<ActivitiesRentablesPage> createState() =>
      _ActivitiesRentablesPageState();
}

class _ActivitiesRentablesPageState extends State<ActivitiesRentablesPage> {
  DateTimeRange? _selectedRange;
  List<RentableItem> rentableItems = [];
  List<Activity> activities = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
      await _loadData();
    }
  }

  Future<void> _clearFilters() async {
    setState(() => _selectedRange = null);
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    String? from;
    String? to;

    if (_selectedRange != null) {
      from = DateFormat('yyyy-MM-dd').format(_selectedRange!.start);
      to = DateFormat('yyyy-MM-dd').format(_selectedRange!.end);
    }

    try {
      final fetchedRentables = await RentableItemService.getAvailable(from, to);
      final fetchedActivities = await ActivityService.getByDateRange(from, to);

      debugPrint("Fetched rentables: ${fetchedRentables.length}");
      debugPrint("Fetched activities: ${fetchedActivities.length}");

      setState(() {
        rentableItems = fetchedRentables;
        activities = fetchedActivities;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() {
        rentableItems = [];
        activities = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildImage(String imageUrl, {double width = 50, double height = 50}) {
    if (imageUrl.startsWith('/')) {
      return Image.network(
        "http://192.168.0.15:5205$imageUrl",
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    } else {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activities & Renting")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _selectedRange == null
                          ? "Select Date Range"
                          : "${DateFormat('dd.MM.yyyy').format(_selectedRange!.start)} - ${DateFormat('dd.MM.yyyy').format(_selectedRange!.end)}",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearFilters,
                  child: const Text("Clear Filters"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                        children: [
                          if (rentableItems.isNotEmpty) ...[
                            const Text(
                              "Available Items",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...rentableItems.map(
                              (item) => ListTile(
                                leading: _buildImage(item.imageUrl),
                                title: Text(item.name),
                                subtitle: Text(
                                  "Available: ${item.availableQuantity}",
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (activities.isNotEmpty) ...[
                            const Text(
                              "Activities",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...activities.map(
                              (a) => ListTile(
                                leading: _buildImage(a.imageUrl),
                                title: Text(a.name),
                                subtitle: Text(
                                  "${a.description}\n${DateFormat('dd.MM.yyyy').format(a.date)}",
                                ),
                                isThreeLine: true,
                              ),
                            ),
                          ],
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
