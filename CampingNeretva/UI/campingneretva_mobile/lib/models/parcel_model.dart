class Parcel {
  final int id;
  final int number;
  final bool shade;
  final bool electricity;
  final String? description;
  final bool isAvailable;
  final String parcelAccommodation;
  final String parcelType;
  final String imageUrl;

  Parcel({
    required this.id,
    required this.number,
    required this.shade,
    required this.electricity,
    required this.description,
    required this.isAvailable,
    required this.parcelAccommodation,
    required this.parcelType,
    required this.imageUrl,
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    return Parcel(
      id: json['parcelId'],
      number: json['parcelNumber'],
      shade: json['shade'],
      electricity: json['electricity'],
      description: json['description'],
      isAvailable: json['availabilityStatus'],
      parcelAccommodation:
          json['parcelAccommodation']?['parcelAccommodation1'] ?? "Unknown",
      parcelType: json['parcelType']?['parcelType1'] ?? "Unknown",
      imageUrl:
          (json['images'] as List).isNotEmpty
              ? json['images'][0]['path']
              : 'assets/default_parcel.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parcelId': id,
      'parcelNumber': number,
      'shade': shade,
      'electricity': electricity,
      'description': description,
      'availabilityStatus': isAvailable,
      'parcelAccommodation': {'parcelAccommodation1': parcelAccommodation},
      'parcelType': {'parcelType1': parcelType},
      'images': [
        {'path': imageUrl},
      ],
    };
  }
}
