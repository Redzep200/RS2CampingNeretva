class Facility {
  final int id;
  final String facilityType;
  final String? description;
  final String imageUrl;

  Facility({
    required this.id,
    required this.facilityType,
    required this.description,
    required this.imageUrl,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['facilityId'],
      facilityType: json['facilityType'],
      description: json['description'],
      imageUrl:
          (json['images'] as List).isNotEmpty
              ? json['images'][0]['path']
              : 'assets/default_facility.png',
    );
  }
}
