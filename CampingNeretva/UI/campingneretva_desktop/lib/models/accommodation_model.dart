class Accommodation {
  final int id;
  final String type;
  double price;
  final String imageUrl;
  int? imageId;

  Accommodation({
    required this.id,
    required this.type,
    required this.price,
    required this.imageUrl,
    this.imageId,
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
      imageId: json['imageId'],
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
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {'type': type, 'pricePerNight': price, 'imageId': imageId ?? 0};
  }
}
