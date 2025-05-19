class Facility {
  final int id;
  final String facilityType;
  final String? description;
  final String imageUrl;
  int? imageId;

  Facility({
    required this.id,
    required this.facilityType,
    required this.description,
    required this.imageUrl,
    this.imageId,
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
      imageId: json['imageId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facilityId': id,
      'facilityType': facilityType,
      'description': description,
      'images': [
        {'path': imageUrl},
      ],
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'facilityType': facilityType,
      'description': description,
      'imageId': imageId ?? 0,
    };
  }
}
