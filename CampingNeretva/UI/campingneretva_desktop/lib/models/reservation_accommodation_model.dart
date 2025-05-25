import 'accommodation_model.dart';

class ReservationAccommodationModel {
  final int quantity;
  final Accommodation accommodation;

  ReservationAccommodationModel({
    required this.quantity,
    required this.accommodation,
  });

  factory ReservationAccommodationModel.fromJson(Map<String, dynamic> json) {
    return ReservationAccommodationModel(
      quantity: json['quantity'],
      accommodation: Accommodation.fromJson(json['accommodation']),
    );
  }
}
