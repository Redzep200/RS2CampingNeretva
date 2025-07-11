import 'package:campingneretva_desktop/models/parcel_accommodation_model.dart';
import 'package:campingneretva_desktop/models/parcel_type_model.dart';

class Parcel {
  final int id;
  final int number;
  final bool shade;
  final bool electricity;
  final String? description;
  bool isAvailable;
  final ParcelAccommodation parcelAccommodation;
  final ParcelType parcelType;
  final String imageUrl;
  int? imageId;

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
    this.imageId,
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
          json['parcelAccommodation'] != null
              ? ParcelAccommodation.fromJson(json['parcelAccommodation'])
              : ParcelAccommodation(id: 0, name: 'Unknown'),
      parcelType:
          json['parcelType'] != null
              ? ParcelType.fromJson(json['parcelType'])
              : ParcelType(id: 0, name: 'Unknown'),
      imageUrl:
          (json['images'] as List).isNotEmpty
              ? json['images'][0]['path']
              : 'assets/default_parcel.png',
      imageId: json['imageId'],
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
      'parcelAccommodationId': parcelAccommodation.id,
      'parcelTypeId': parcelType.id,
      'images': [
        {'path': imageUrl},
      ],
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'parcelNumber': number,
      'shade': shade,
      'electricity': electricity,
      'description': description,
      'availabilityStatus': isAvailable,
      'parcelAccommodationId': parcelAccommodation.id,
      'parcelTypeId': parcelType.id,
      'imageId': imageId ?? 0,
    };
  }
}
