import 'package:flutter/material.dart';
import '../models/acommodation_model.dart';
import '../models/vehicle_model.dart';
import '../models/person_model.dart';
import '../services/acommodation_service.dart';
import '../services/vehicle_service.dart';
import '../services/person_service.dart';
import '../widgets/app_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String baseUrl = "http://10.0.2.2:5205";

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
      final a = await AccommodationService.getAccommodations();
      final v = await VehicleService.getVehicles();
      final p = await PersonService.getPersons();

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
          style: const TextStyle(
            fontFamily: 'MochiyPop',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
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

    final String fullImageUrl = "${HomePage.baseUrl}$image";

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Image.network(
                  fullImageUrl,
                  fit: BoxFit.cover,
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
            Container(
              color: Colors.green.shade100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'MochiyPop',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${price.toStringAsFixed(2)} KM",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
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
    return AppScaffold(
      title: 'Camping Neretva',
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
