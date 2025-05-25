import 'user_model.dart';
import 'parcel_model.dart';
import 'activity_model.dart';
import 'reservation_accommodation_model.dart';
import 'reservation_person_model.dart';
import 'reservation_rentable_item_model.dart';
import 'reservation_vehicle_model.dart';

class Reservation {
  final int reservationId;
  final DateTime startDate;
  final DateTime endDate;
  final User user;
  final Parcel parcel;
  final List<ReservationPersonModel> persons;
  final List<ReservationVehicleModel> vehicles;
  final List<ReservationAccommodationModel> accommodations;
  List<ReservationRentableItemModel>? rentableItems;
  List<Activity>? activities;
  final double totalPrice;
  final String paymentStatus;

  Reservation({
    required this.reservationId,
    required this.startDate,
    required this.endDate,
    required this.user,
    required this.parcel,
    required this.persons,
    required this.vehicles,
    required this.accommodations,
    this.rentableItems,
    this.activities,
    required this.totalPrice,
    required this.paymentStatus,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservationId: json['reservationId'],
      startDate: DateTime.parse(json['checkInDate']),
      endDate: DateTime.parse(json['checkOutDate']),
      user: User.fromJson(json['user']),
      parcel: Parcel.fromJson(json['parcel']),
      persons:
          (json['reservationPeople'] as List)
              .map((e) => ReservationPersonModel.fromJson(e))
              .toList(),
      vehicles:
          (json['reservationVehicles'] as List)
              .map((e) => ReservationVehicleModel.fromJson(e))
              .toList(),
      accommodations:
          (json['reservationAccommodations'] as List)
              .map((e) => ReservationAccommodationModel.fromJson(e))
              .toList(),
      rentableItems:
          json['reservationRentables'] == null
              ? null
              : (json['reservationRentables'] as List)
                  .map(
                    (e) => ReservationRentableItemModel.fromJson(
                      e as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
      activities:
          json['activities'] == null
              ? null
              : (json['activities'] as List)
                  .map((e) => Activity.fromJson(e as Map<String, dynamic>))
                  .toList(),
      totalPrice: json['totalPrice'].toDouble(),
      paymentStatus: json['paymentStatus'],
    );
  }
}
