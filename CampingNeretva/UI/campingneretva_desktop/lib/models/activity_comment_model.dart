class ActivityComment {
  final int activityCommentId;
  final int activityId;
  final int userId;
  final String commentText;
  final int rating;
  final DateTime datePosted;

  ActivityComment({
    required this.activityCommentId,
    required this.activityId,
    required this.userId,
    required this.commentText,
    required this.rating,
    required this.datePosted,
  });

  factory ActivityComment.fromJson(Map<String, dynamic> json) {
    return ActivityComment(
      activityCommentId: json['activityCommentId'],
      activityId: json['activityId'],
      userId: json['userId'],
      commentText: json['commentText'],
      rating: json['rating'],
      datePosted: DateTime.parse(json['datePosted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'userId': userId,
      'commentText': commentText,
      'rating': rating,
    };
  }
}
