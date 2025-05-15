class Accommodation {
  final int id;
  final String type;
  double price;
  final String imageUrl;

  Accommodation({
    required this.id,
    required this.type,
    required this.price,
    required this.imageUrl,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      id: json['accommodationId'],
      type: json['type'],
      price: json['pricePerNight'].toDouble(),
      imageUrl:
          (json['images'] as List).isNotEmpty
              ? json['images'][0]['path']
              : 'assets/default_xxx.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accommodationId': id,
      'type': type,
      'pricePerNight': price,
      'images': [
        {'path': imageUrl},
      ],
    };
  }
}
