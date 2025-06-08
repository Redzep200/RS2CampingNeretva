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
  List<RentableItem> recommendedRentableItems = [];
  List<Activity> recommendedActivities = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadRecommendedData();
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

  Future<void> _loadRecommendedData() async {
    try {
      final fetchedRecommendedRentables =
          await RentableItemService.getRecommendedRentableItems();
      final fetchedRecommendedActivities =
          await ActivityService.getRecommendedActivities();

      debugPrint(
        "Fetched recommended rentables: ${fetchedRecommendedRentables.length}",
      );
      debugPrint(
        "Fetched recommended activities: ${fetchedRecommendedActivities.length}",
      );

      setState(() {
        recommendedRentableItems = fetchedRecommendedRentables;
        recommendedActivities = fetchedRecommendedActivities;
      });
    } catch (e) {
      debugPrint("Error loading recommended data: $e");
    }
  }

  Widget _buildItemTile({
    required String name,
    required String? imageUrl,
    required String subtitle,
    bool isRecommended = false,
    bool isThreeLine = false,
  }) {
    return ListTile(
      tileColor: isRecommended ? Colors.green[50] : null,
      leading: _buildImage(imageUrl, width: 60, height: 60),
      title: Row(
        children: [
          Text(name),
          if (isRecommended)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "Recommended",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        subtitle,
        maxLines: isThreeLine ? 3 : 1,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: isThreeLine,
    );
  }

  Widget _buildImage(
    String? imageUrl, {
    double width = 50,
    double height = 50,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(Icons.broken_image, size: 50);
    }
    if (imageUrl.startsWith('/')) {
      return Image.network(
        "http://10.0.2.2:5205$imageUrl",
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
        errorBuilder:
            (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activities & Rentables")),
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
                  child: const Text("Clear"),
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
                              (item) => _buildItemTile(
                                name: item.name,
                                imageUrl: item.imageUrl,
                                subtitle:
                                    "Available: ${item.availableQuantity}",
                                isRecommended: recommendedRentableItems.any(
                                  (ri) => ri.id == item.id,
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
                              (a) => _buildItemTile(
                                name: a.name,
                                imageUrl: a.imageUrl,
                                subtitle:
                                    "${a.description ?? 'No description'}\n${DateFormat('dd.MM.yyyy').format(a.date)}",
                                isRecommended: recommendedActivities.any(
                                  (ra) => ra.id == a.id,
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
