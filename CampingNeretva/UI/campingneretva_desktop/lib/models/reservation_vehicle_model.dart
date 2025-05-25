import 'vehicle_model.dart';

class ReservationVehicleModel {
  final int quantity;
  final Vehicle vehicle;

  ReservationVehicleModel({required this.quantity, required this.vehicle});

  factory ReservationVehicleModel.fromJson(Map<String, dynamic> json) {
    return ReservationVehicleModel(
      quantity: json['quantity'],
      vehicle: Vehicle.fromJson(json['vehicle']),
    );
  }
}
