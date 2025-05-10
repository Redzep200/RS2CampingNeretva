class Worker {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;

  Worker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['workerId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }

  String get fullName => "$firstName $lastName";
}
