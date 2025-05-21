import 'facility_model.dart';

class Activity {
  final int id;
  final String name;
  final String description;
  final DateTime date;
  final double price;
  final String imageUrl;
  int? imageId;
  Facility? facility;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.price,
    required this.imageUrl,
    this.imageId,
    this.facility,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['activityId'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      price: json['price'],
      imageUrl:
          (json['images'] as List).isNotEmpty
              ? json['images'][0]['path']
              : 'assets/default_activity.png',
      imageId: json['imageId'],
      facility:
          json['facility'] != null ? Facility.fromJson(json['facility']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityId': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'price': price,
      'images': [
        {'path': imageUrl},
      ],
      'imageId': imageId,
      'facilityId': facility?.id,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'price': price,
      'imageId': imageId ?? 0,
      'facilityId': facility?.id,
    };
  }
}
