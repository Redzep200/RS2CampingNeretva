import 'package:campingneretva_mobile/models/user_model.dart';
import 'package:campingneretva_mobile/models/worker_model.dart';

class Review {
  final int id;
  final String comment;
  final int rating;
  final String datePosted;
  final User user;
  final Worker worker;

  Review({
    required this.id,
    required this.comment,
    required this.rating,
    required this.datePosted,
    required this.user,
    required this.worker,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['reviewId'],
      comment: json['comment'],
      rating: json['rating'],
      datePosted: json['datePosted'],
      user: User.fromJson(json['user']),
      worker: Worker.fromJson(json['worker']),
    );
  }
}
