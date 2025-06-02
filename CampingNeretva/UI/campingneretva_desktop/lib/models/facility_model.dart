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
    String extractedImageUrl = 'assets/default_image.png';
    int? extractedImageId;

    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final firstImage = json['images'][0];
      extractedImageUrl = firstImage['path'] ?? 'assets/default_image.png';
      extractedImageId = firstImage['imageId'];
    }
    return Facility(
      id: json['facilityId'],
      facilityType: json['facilityType'],
      description: json['description'],
      imageUrl: extractedImageUrl,
      imageId: extractedImageId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facilityId': id,
      'facilityType': facilityType,
      'description': description,
      'images': [
        {'path': imageUrl, 'imageId': imageId},
      ],
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'facilityType': facilityType,
      'description': description,
      'imageId': imageId,
    };
  }
}
