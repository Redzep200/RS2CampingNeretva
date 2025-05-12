class RentableItem {
  final int id;
  final String name;
  final int availableQuantity;
  final String imageUrl;
  final double pricePerDay;
  final String description;

  RentableItem({
    required this.id,
    required this.name,
    required this.availableQuantity,
    required this.imageUrl,
    required this.description,
    required this.pricePerDay,
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
    };
  }
}
