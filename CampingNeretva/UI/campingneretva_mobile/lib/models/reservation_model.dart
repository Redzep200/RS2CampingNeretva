import 'package:campingneretva_mobile/models/user_model.dart';
import 'package:campingneretva_mobile/models/parcel_model.dart';
import 'package:campingneretva_mobile/models/acommodation_model.dart';
import 'package:campingneretva_mobile/models/person_model.dart';
import 'package:campingneretva_mobile/models/vehicle_model.dart';
import 'package:campingneretva_mobile/models/rentable_item_model.dart';
import 'package:campingneretva_mobile/models/activity_model.dart';
import 'package:campingneretva_mobile/services/auth_service.dart';

class Reservation {
  final int reservationId;
  final DateTime startDate;
  final DateTime endDate;
  final User user;
  final Parcel parcel;
  final Accommodation accommodation;
  final List<PersonType> persons;
  final List<Vehicle> vehicles;
  final List<RentableItem> rentableItems;
  final List<Activity> activities;

  Reservation({
    required this.reservationId,
    required this.startDate,
    required this.endDate,
    required this.user,
    required this.parcel,
    required this.accommodation,
    required this.persons,
    required this.vehicles,
    required this.rentableItems,
    required this.activities,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservationId: json['reservationId'],
      startDate: DateTime.parse(json['checkInDate']),
      endDate: DateTime.parse(json['checkOutDate']),
      user:
          json['user'] != null
              ? User.fromJson(json['user'])
              : AuthService.currentUser!,

      parcel: Parcel.fromJson(json['parcel']),
      persons:
          (json['reservationPeople'] as List)
              .map((e) => PersonType.fromJson(e['person']))
              .toList(),

      vehicles:
          (json['reservationVehicles'] as List)
              .map((e) => Vehicle.fromJson(e['vehicle']))
              .toList(),

      accommodation:
          (json['reservationAccommodations'] as List).isNotEmpty
              ? Accommodation.fromJson(
                json['reservationAccommodations'][0]['accommodation'],
              )
              : throw Exception('No accommodation found in reservation'),

      rentableItems:
          (json['reservationRentables'] as List)
              .map((e) => RentableItem.fromJson(e['item']))
              .toList(),

      activities:
          (json['activities'] as List)
              .map((e) => Activity.fromJson(e))
              .toList(),
    );
  }
}
