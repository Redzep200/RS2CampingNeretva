import 'rentable_item_model.dart';

class ReservationRentableItemModel {
  final int quantity;
  final RentableItem item;

  ReservationRentableItemModel({required this.quantity, required this.item});

  factory ReservationRentableItemModel.fromJson(Map<String, dynamic> json) {
    return ReservationRentableItemModel(
      quantity: json['quantity'],
      item: RentableItem.fromJson(json['item']),
    );
  }
}
