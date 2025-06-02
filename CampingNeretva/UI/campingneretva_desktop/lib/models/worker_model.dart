import 'package:campingneretva_desktop/models/role_model.dart';

class Worker {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  List<Role>? roles;
  double? averageRating;

  Worker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    this.roles,
    this.averageRating,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['workerId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      roles:
          json['roles'] == null
              ? null
              : (json['roles'] as List)
                  .map((e) => Role.fromJson(e as Map<String, dynamic>))
                  .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workerId': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'roles': roles?.map((role) => role.toJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'roles': roles?.map((r) => r.id).toList() ?? [],
    };
  }

  String get fullName => "$firstName $lastName";
}
