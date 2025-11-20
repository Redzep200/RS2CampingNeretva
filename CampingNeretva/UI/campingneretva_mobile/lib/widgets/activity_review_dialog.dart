import 'package:flutter/material.dart';
import '../services/activity_comment_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

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

  Future<void> _submitReview() async {
    if (rating == 0 || commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter rating and comment")),
      );
      return;
    }

    if (!AuthService.isLoggedIn()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must be logged in to leave a review"),
        ),
      );
      return;
    }

    setState(() => submitting = true);

    final userId = AuthService.currentUser!.id;

    final success = await ActivityCommentService.addComment(
      activityId: widget.activityId,
      userId: userId,
      commentText: commentController.text.trim(),
      rating: rating,
    );

    setState(() => submitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to submit review")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Review"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(
                icon: Icon(
                  star <= rating ? Icons.star : Icons.star_border,
                  size: 32,
                ),
                onPressed: () => setState(() => rating = star),
              );
            }),
          ),
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Comment"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: submitting ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: submitting ? null : _submitReview,
          child:
              submitting
                  ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text("Submit"),
        ),
      ],
    );
  }
}
