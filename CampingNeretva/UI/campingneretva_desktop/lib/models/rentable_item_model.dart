class RentableItem {
  final int id;
  final String name;
  int? availableQuantity;
  final String imageUrl;
  final double pricePerDay;
  final String description;
  int? imageId;
  final int totalQuantity;

  RentableItem({
    required this.id,
    required this.name,
    this.availableQuantity,
    required this.imageUrl,
    required this.description,
    required this.pricePerDay,
    this.imageId,
    required this.totalQuantity,
  });

  factory RentableItem.fromJson(Map<String, dynamic> json) {
    return RentableItem(
      id: json['itemId'],
      name: json['name'],
      description: json['description'],
      pricePerDay: json['pricePerDay'],
      availableQuantity: json['availableQuantity'],
      imageUrl:
          (json['images'] as List).isNotEmpty
              ? json['images'][0]['path']
              : 'assets/default_rentableitem.png',
      imageId: json['imageId'],
      totalQuantity: json['totalQuantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': id,
      'name': name,
      'description': description,
      'pricePerDay': pricePerDay,
      'availableQuantity': availableQuantity,
      'images': [
        {'path': imageUrl},
      ],
      'imageId': imageId,
      'totalQuantity': totalQuantity,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'pricePerDay': pricePerDay,
      'totalQuantity': totalQuantity,
      'imageId': imageId ?? 0,
    };
  }
}
