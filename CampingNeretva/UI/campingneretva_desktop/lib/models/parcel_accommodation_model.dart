class ParcelAccommodation {
  final int id;
  final String name;

  ParcelAccommodation({required this.id, required this.name});

  factory ParcelAccommodation.fromJson(Map<String, dynamic> json) {
    return ParcelAccommodation(
      id: json['parcelAccommodationId'],
      name: json['parcelAccommodation1'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'parcelAccommodationId': id, 'parcelAccommodation1': name};
  }

  @override
  String toString() => name;
}
