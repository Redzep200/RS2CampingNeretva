import 'package:flutter/material.dart';
import '../models/activity_comment_model.dart';
import '../models/user_model.dart';
import '../services/activity_comment_service.dart';
import '../services/user_service.dart';
import 'package:intl/intl.dart';

class ActivityReviewsDialog extends StatefulWidget {
  final int activityId;
  final String activityName;

  const ActivityReviewsDialog({
    super.key,
    required this.activityId,
    required this.activityName,
  });

  @override
  State<ActivityReviewsDialog> createState() => _ActivityReviewsDialogState();
}

class _ActivityReviewsDialogState extends State<ActivityReviewsDialog> {
  List<ActivityComment> reviews = [];
  Map<int, User> userCache = {};
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      reviews = await ActivityCommentService.getByActivityId(widget.activityId);

      // Load user details for each review
      final userService = UserService();
      for (var review in reviews) {
        if (!userCache.containsKey(review.userId)) {
          try {
            final user = await userService.getById(review.userId);
            userCache[review.userId] = user;
          } catch (e) {
            print('Error loading user ${review.userId}: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading reviews: $e');
      errorMessage = 'Failed to load reviews: $e';
    } finally {
      setState(() => loading = false);
    }
  }

  double _calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  Widget _buildReviewsList() {
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No reviews yet",
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final review = reviews[index];
        final user = userCache[review.userId];

        return ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green,
            child: Text(
              user?.firstName[0].toUpperCase() ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                user != null
                    ? '${user.firstName} ${user.lastName}'
                    : 'User ${review.userId}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              ...List.generate(
                5,
                (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(review.datePosted),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                review.commentText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avgRating = _calculateAverageRating();

    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.activityName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (reviews.isNotEmpty)
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < avgRating.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${avgRating.toStringAsFixed(1)} • ${reviews.length} ${reviews.length == 1 ? "review" : "reviews"}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child:
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadReviews,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                      : _buildReviewsList(),
            ),
          ],
        ),
      ),
    );
  }
}
