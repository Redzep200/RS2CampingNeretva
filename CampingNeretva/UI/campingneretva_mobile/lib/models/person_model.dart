class PersonType {
  final int id;
  final String type;
  final double price;
  final String imageUrl;

  PersonType({
    required this.id,
    required this.type,
    required this.price,
    required this.imageUrl,
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
    };
  }
}
