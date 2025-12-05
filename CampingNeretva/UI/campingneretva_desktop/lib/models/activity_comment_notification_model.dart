import 'activity_comment_model.dart';

class ActivityCommentNotification {
  final int notificationId;
  final int activityId;
  final String activityName;
  final String category;
  final String sentiment;
  final String summary;
  final List<int> relatedCommentIds;
  final String status;
  final DateTime dateCreated;
  final DateTime? dateReviewed;
  final int? reviewedBy;

  ActivityCommentNotification({
    required this.notificationId,
    required this.activityId,
    required this.activityName,
    required this.category,
    required this.sentiment,
    required this.summary,
    required this.relatedCommentIds,
    required this.status,
    required this.dateCreated,
    this.dateReviewed,
    this.reviewedBy,
  });

  factory ActivityCommentNotification.fromJson(Map<String, dynamic> json) {
    return ActivityCommentNotification(
      notificationId: json['notificationId'],
      activityId: json['activityId'],
      activityName: json['activityName'],
      category: json['category'],
      sentiment: json['sentiment'],
      summary: json['summary'],
      relatedCommentIds:
          (json['relatedCommentIds'] as String)
              .split(',')
              .map((e) => int.parse(e.trim()))
              .toList(),
      status: json['status'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateReviewed:
          json['dateReviewed'] != null
              ? DateTime.parse(json['dateReviewed'])
              : null,
      reviewedBy: json['reviewedBy'],
    );
  }
}

class CommentAnalysisResult {
  final int activityId;
  final String activityName;
  final String category;
  final String sentiment;
  final List<ActivityComment> relatedComments;
  final String aiSummary;

  CommentAnalysisResult({
    required this.activityId,
    required this.activityName,
    required this.category,
    required this.sentiment,
    required this.relatedComments,
    required this.aiSummary,
  });

  factory CommentAnalysisResult.fromJson(Map<String, dynamic> json) {
    return CommentAnalysisResult(
      activityId: json['activityId'],
      activityName: json['activityName'],
      category: json['category'],
      sentiment: json['sentiment'],
      relatedComments:
          (json['relatedComments'] as List)
              .map((e) => ActivityComment.fromJson(e))
              .toList(),
      aiSummary: json['aiSummary'],
    );
  }
}
