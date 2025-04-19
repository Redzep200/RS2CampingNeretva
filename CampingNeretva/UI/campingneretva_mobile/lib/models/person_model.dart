class PersonType {
  final int id;
  final String label;
  final double price;
  final String imageUrl;

  PersonType({
    required this.id,
    required this.label,
    required this.price,
    required this.imageUrl,
  });

  factory PersonType.fromJson(Map<String, dynamic> json) {
    return PersonType(
      id: json['id'],
      label: json['type'],
      price: json['pricePerNight'].toDouble(),
      imageUrl: json['imageUrl'] ?? 'assets/default_person.png',
    );
  }
}
