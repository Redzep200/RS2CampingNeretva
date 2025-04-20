class Accommodation {
  final int id;
  final String name;
  final double price;
  final String imageUrl;

  Accommodation({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      id: json['id'],
      name: json['name'],
      price: json['pricePerNight'].toDouble(),
      imageUrl:
          (json['images'] as List).isNotEmpty
              ? json['images'][0]['path']
              : 'assets/default_xxx.png',
    );
  }
}
