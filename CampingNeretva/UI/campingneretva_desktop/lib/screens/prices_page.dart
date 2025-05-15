import 'package:flutter/material.dart';
import '../models/accommodation_model.dart';
import '../models/person_model.dart';
import '../models/vehicle_model.dart';
import '../services/accommodation_service.dart';
import '../services/person_service.dart';
import '../services/vehicle_service.dart';
import '../widgets/navbar.dart';

class PricePage extends StatefulWidget {
  const PricePage({super.key});
  static const String baseUrl = "http://localhost:5205";

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  bool loading = true;
  static const String _baseUrl = "http://localhost:5205";
  List<Accommodation> accommodations = [];
  List<PersonType> persons = [];
  List<Vehicle> vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    accommodations = await AccommodationService.fetchAll();
    persons = await PersonService.fetchAll();
    vehicles = await VehicleService.fetchAll();
    setState(() => loading = false);
  }

  Widget _buildSectionWithImages<T>({
    required String title,
    required List<T> items,
    required Future<void> Function(T item) onDelete,
    required Future<void> Function(T item, double newPrice) onEdit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (_, index) {
            final item = items[index] as dynamic;
            final imageUrl = "$_baseUrl${item.imageUrl}";

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
                subtitle: Text('€${item.price.toStringAsFixed(2)} / night'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed:
                          () => _showEditDialog(
                            item,
                            onEdit as Future<void> Function(dynamic, double),
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await onDelete(item);
                        _loadAll();
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

  Future<void> _showEditDialog(
    dynamic item,
    Future<void> Function(dynamic, double) onEdit,
  ) async {
    final controller = TextEditingController(text: item.price.toString());
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Price'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'New price (€)'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newPrice = double.tryParse(controller.text);
                  if (newPrice != null) {
                    Navigator.pop(context);
                    await onEdit(item, newPrice);
                    _loadAll();
                  }
                },
                child: const Text('Save'),
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
                    _buildSectionWithImages<Vehicle>(
                      title: '🚗 Vozila',
                      items: vehicles,
                      onDelete: (v) => VehicleService.delete(v.id),
                      onEdit: (v, newPrice) async {
                        v.price = newPrice;
                        await VehicleService.update(v);
                      },
                    ),
                    _buildSectionWithImages<PersonType>(
                      title: '🧍 Osobe',
                      items: persons,
                      onDelete: (p) => PersonService.delete(p.id),
                      onEdit: (p, newPrice) async {
                        p.price = newPrice;
                        await PersonService.update(p);
                      },
                    ),
                    _buildSectionWithImages<Accommodation>(
                      title: '🏕️ Smještaji',
                      items: accommodations,
                      onDelete: (a) => AccommodationService.delete(a.id),
                      onEdit: (a, newPrice) async {
                        a.price = newPrice;
                        await AccommodationService.update(a);
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
    );
  }
}
