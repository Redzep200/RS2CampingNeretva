class Parcel {
  final int parcelId;
  final int parcelNumber;
  final bool shade;
  final bool electricity;
  final bool availabilityStatus;
  final List<String> images;

  Parcel({
    required this.parcelId,
    required this.parcelNumber,
    required this.shade,
    required this.electricity,
    required this.availabilityStatus,
    required this.images,
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    return Parcel(
      parcelId: json['parcelId'],
      parcelNumber: json['parcelNumber'],
      shade: json['shade'],
      electricity: json['electricity'],
      availabilityStatus: json['availabilityStatus'],
      images: List<String>.from(json['images'].map((img) => img['url'])),
    );
  }
}
