class ParcelType {
  final int id;
  final String name;

  ParcelType({required this.id, required this.name});

  factory ParcelType.fromJson(Map<String, dynamic> json) {
    return ParcelType(id: json['parcelTypeId'], name: json['parcelType1']);
  }

  Map<String, dynamic> toJson() {
    return {'parcelTypeId': id, 'parcelType1': name};
  }

  @override
  String toString() => name;
}
