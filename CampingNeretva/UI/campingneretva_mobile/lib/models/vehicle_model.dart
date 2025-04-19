class Vehicle {
  final int id;
  final String type;
  final double price;
  final String imageUrl;

  Vehicle({
    required this.id,
    required this.type,
    required this.price,
    required this.imageUrl,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      type: json['type'],
      price: json['pricePerNight'].toDouble(),
      imageUrl: json['imageUrl'] ?? 'assets/default_vehicle.png',
    );
  }
}
