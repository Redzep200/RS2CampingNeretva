class UserType {
  final int id;
  final String typeName;

  UserType({required this.id, required this.typeName});

  factory UserType.fromJson(Map<String, dynamic> json) {
    return UserType(id: json['userTypeId'], typeName: json['typeName']);
  }
}
