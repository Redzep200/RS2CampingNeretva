import 'package:flutter/material.dart';
import '../models/acommodation_model.dart';
import '../models/vehicle_model.dart';
import '../models/person_model.dart';
import '../services/acommodation_service.dart';
import '../services/vehicle_service.dart';
import '../services/person_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String baseUrl = "http://192.168.0.15:5205";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _accommodationService = AccommodationService();
  final _vehicleService = VehicleService();
  final _personService = PersonService();

  List<Accommodation> accommodations = [];
  List<Vehicle> vehicles = [];
  List<PersonType> persons = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final a = await _accommodationService.getAccommodations();
      final v = await _vehicleService.getVehicles();
      final p = await _personService.getPersons();

      setState(() {
        accommodations = a;
        vehicles = v;
        persons = p;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Widget _buildSection<T>(String title, List<T> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (_, index) => _buildCard(items[index]),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCard(dynamic item) {
    String title = '';
    double price = 0;
    String image = '';

    if (item is Accommodation) {
      title = item.type;
      price = item.price;
      image = item.imageUrl;
    } else if (item is Vehicle) {
      title = item.type;
      price = item.price;
      image = item.imageUrl;
    } else if (item is PersonType) {
      title = item.type;
      price = item.price;
      image = item.imageUrl;
    }

    print("Image path from backend: $image");

    final String fullImageUrl = "${HomePage.baseUrl}$image";
    print("Full image URL: $fullImageUrl");

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fullImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '${price.toStringAsFixed(2)} KM',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camping Neretva')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection("Accommodations", accommodations),
                    _buildSection("Vehicles", vehicles),
                    _buildSection("Persons", persons),
                  ],
                ),
              ),
    );
  }
}
