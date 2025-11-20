import 'package:flutter/material.dart';
import '../services/activity_comment_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/activity_comment_model.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class ActivityReviewDialog extends StatefulWidget {
  final int activityId;

  const ActivityReviewDialog({super.key, required this.activityId});

  @override
  State<ActivityReviewDialog> createState() => _ActivityReviewDialogState();
}

class _ActivityReviewDialogState extends State<ActivityReviewDialog> {
  int rating = 0;
  final TextEditingController commentController = TextEditingController();
  bool submitting = false;
  bool loading = true;
  ActivityComment? userExistingReview;
  List<ActivityComment> reviews = [];
  Map<int, User> userCache = {};

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => loading = true);

    try {
      // Check if current user has already reviewed
      if (AuthService.isLoggedIn()) {
        userExistingReview = await ActivityCommentService.getUserReview(
          activityId: widget.activityId,
          userId: AuthService.currentUser!.id,
        );

        // Pre-fill form if user has existing review
        if (userExistingReview != null) {
          rating = userExistingReview!.rating;
          commentController.text = userExistingReview!.commentText;
        }
      }

      // Load all reviews for this activity
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
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _submitReview() async {
    if (rating == 0 || commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter rating and comment")),
      );
      return;
    }

    setState(() => submitting = true);

    bool success;
    String successMessage;

    if (userExistingReview != null) {
      // Update existing review
      success = await ActivityCommentService.updateComment(
        commentId: userExistingReview!.activityCommentId,
        commentText: commentController.text.trim(),
        rating: rating,
      );
      successMessage = "Review updated successfully";
    } else {
      // Add new review
      final userId = AuthService.currentUser!.id;
      success = await ActivityCommentService.addComment(
        activityId: widget.activityId,
        userId: userId,
        commentText: commentController.text.trim(),
        rating: rating,
      );
      successMessage = "Review submitted successfully";
    }

    setState(() => submitting = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      // Reload reviews to show the updated one
      await _loadReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userExistingReview != null
                ? "Failed to update review"
                : "Failed to submit review",
          ),
        ),
      );
    }
  }

  Future<void> _deleteReview() async {
    if (userExistingReview == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Review"),
            content: const Text("Are you sure you want to delete your review?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => submitting = true);

    try {
      await ActivityCommentService.delete(
        userExistingReview!.activityCommentId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review deleted successfully")),
      );
      // Clear form and reload
      setState(() {
        rating = 0;
        commentController.clear();
        userExistingReview = null;
      });
      await _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete review")));
    } finally {
      setState(() => submitting = false);
    }
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              userExistingReview != null
                  ? "Update Your Review"
                  : "Add Your Review",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (userExistingReview != null)
              TextButton.icon(
                onPressed: submitting ? null : _deleteReview,
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                label: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        if (userExistingReview != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "You can edit your existing review below",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final star = index + 1;
            return IconButton(
              icon: Icon(
                star <= rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
              onPressed: () => setState(() => rating = star),
            );
          }),
        ),
        TextField(
          controller: commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Your Comment",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submitting ? null : _submitReview,
            child:
                submitting
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(
                      userExistingReview != null
                          ? "Update Review"
                          : "Submit Review",
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            "No reviews yet. Be the first to review!",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          "Reviews (${reviews.length})",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final review = reviews[index];
            final user = userCache[review.userId];
            final isCurrentUser =
                AuthService.isLoggedIn() &&
                review.userId == AuthService.currentUser!.id;

            return Container(
              decoration:
                  isCurrentUser
                      ? BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      )
                      : null,
              child: ListTile(
                contentPadding:
                    isCurrentUser
                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                        : EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: isCurrentUser ? Colors.blue : null,
                  child: Text(
                    user?.firstName[0].toUpperCase() ?? '?',
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : null,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      user != null
                          ? '${user.firstName} ${user.lastName}'
                          : 'User ${review.userId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (isCurrentUser)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Your Review",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    const SizedBox(width: 8),
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(review.datePosted),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(review.commentText),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Activity Reviews",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildReviewForm(),
                      _buildReviewsList(),
                    ],
                  ),
                ),
      ),
    );
  }
}
