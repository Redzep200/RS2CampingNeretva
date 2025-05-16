class PersonType {
  final int id;
  final String type;
  double price;
  final String imageUrl;
  int? imageId;

  PersonType({
    required this.id,
    required this.type,
    required this.price,
    required this.imageUrl,
    this.imageId,
  });

  factory PersonType.fromJson(Map<String, dynamic> json) {
    return PersonType(
      id: json['personId'],
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
      'personId': id,
      'type': type,
      'pricePerNight': price,
      'images': [
        {'path': imageUrl},
      ],
      'imageId': imageId,
    };
  }
}
