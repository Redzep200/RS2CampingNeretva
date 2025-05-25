import 'person_model.dart';

class ReservationPersonModel {
  final int quantity;
  final PersonType person;

  ReservationPersonModel({required this.quantity, required this.person});

  factory ReservationPersonModel.fromJson(Map<String, dynamic> json) {
    return ReservationPersonModel(
      quantity: json['quantity'],
      person: PersonType.fromJson(json['person']),
    );
  }
}
