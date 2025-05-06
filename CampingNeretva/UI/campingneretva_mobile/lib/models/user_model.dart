import 'package:campingneretva_mobile/models/user_type_model.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserType userType;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'],
      username: json['userName'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      userType: UserType.fromJson(json['userType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'userTypeId': userType.id,
    };
  }
}
