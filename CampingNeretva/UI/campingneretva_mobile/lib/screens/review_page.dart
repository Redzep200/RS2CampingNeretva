import 'package:flutter/material.dart';
import 'package:campingneretva_mobile/models/review_model.dart';
import 'package:campingneretva_mobile/models/worker_model.dart';
import 'package:campingneretva_mobile/services/review_service.dart';
import 'package:campingneretva_mobile/services/worker_service.dart';
import 'package:campingneretva_mobile/services/auth_service.dart';
import 'package:campingneretva_mobile/widgets/app_scaffold.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<Review> reviews = [];
  List<Worker> workers = [];
  Worker? selectedWorker;
  int rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = true;
  String? errorMessage;

  // Map to track if a user has reviewed a worker
  Map<int, Review> userReviewsByWorker = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      workers = await WorkerService.getAll();
      await _loadReviews();
    } catch (e) {
      errorMessage = 'Failed to load data: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    final user = AuthService.currentUser;
    reviews = await ReviewService.getAll(workerId: selectedWorker?.id);
    userReviewsByWorker.clear();

    if (user != null) {
      for (var review in reviews) {
        if (review.user.id == user.id) {
          userReviewsByWorker[review.worker.id] = review;
        }
      }
    }

    // Sort user's review first
    reviews.sort((a, b) {
      if (user != null) {
        if (a.user.id == user.id && b.user.id != user.id) return -1;
        if (a.user.id != user.id && b.user.id == user.id) return 1;
      }
      return b.datePosted.compareTo(a.datePosted);
    });
  }

  Future<void> _submitReview() async {
    if (selectedWorker == null ||
        rating == 0 ||
        _commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final user = AuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a review'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Check if the user already has a review for this worker
      final existingReview = userReviewsByWorker[selectedWorker!.id];

      if (existingReview != null) {
        // Update existing review
        await ReviewService.update(
          reviewId: existingReview.id,
          rating: rating,
          comment: _commentController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review updated successfully')),
        );
      } else {
        // Submit new review
        await ReviewService.submit(
          userId: user.id,
          workerId: selectedWorker!.id,
          rating: rating,
          comment: _commentController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }

      _commentController.clear();
      rating = 0;
      await _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      print('Error submitting review: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _editReview(Review review) {
    setState(() {
      selectedWorker = review.worker;
      rating = review.rating;
      _commentController.text = review.comment;
    });
  }

  double _calculateAverageRating() {
    final workerReviews = reviews.where(
      (r) => r.worker.id == selectedWorker!.id,
    );
    if (workerReviews.isEmpty) return 0;
    final total = workerReviews.map((r) => r.rating).reduce((a, b) => a + b);
    return total / workerReviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return AppScaffold(
      title: 'Rate Employees',
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Worker dropdown
                    DropdownButton<Worker>(
                      hint: const Text('Select Worker'),
                      value: selectedWorker,
                      isExpanded: true,
                      items:
                          workers.map((worker) {
                            return DropdownMenuItem<Worker>(
                              value: worker,
                              child: Text(worker.fullName),
                            );
                          }).toList(),
                      onChanged: (value) async {
                        selectedWorker = value;
                        await _loadReviews(); // fetch filtered reviews
                        setState(() {}); // re-render UI
                      },
                    ),
                    const SizedBox(height: 16),

                    // Review title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedWorker == null
                              ? 'All Reviews'
                              : 'Reviews for ${selectedWorker!.fullName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selectedWorker != null)
                          Text(
                            'Average rating: ${_calculateAverageRating().toStringAsFixed(1)} / 5',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Only show review form if user is logged in
                    if (user != null) ...[
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'Write a comment...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              Icons.star,
                              color:
                                  rating > index ? Colors.amber : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                rating = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                      ElevatedButton(
                        onPressed: _submitReview,
                        child: Text(
                          selectedWorker != null &&
                                  userReviewsByWorker.containsKey(
                                    selectedWorker!.id,
                                  )
                              ? 'Update Review'
                              : 'Submit Review',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Reviews list
                    Expanded(
                      child:
                          reviews.isEmpty
                              ? const Center(child: Text('No reviews yet'))
                              : ListView.builder(
                                itemCount: reviews.length,
                                itemBuilder: (context, index) {
                                  final review = reviews[index];
                                  final isUserReview =
                                      user != null && review.user.id == user.id;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(review.comment),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: List.generate(
                                              5,
                                              (i) => Icon(
                                                Icons.star,
                                                size: 16,
                                                color:
                                                    review.rating > i
                                                        ? Colors.amber
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'By: ${review.user.firstName} ${review.user.lastName}',
                                            style: TextStyle(
                                              fontStyle:
                                                  isUserReview
                                                      ? FontStyle.italic
                                                      : FontStyle.normal,
                                              fontWeight:
                                                  isUserReview
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            'For: ${review.worker.fullName}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Posted: ${review.datePosted}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing:
                                          isUserReview
                                              ? IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed:
                                                    () => _editReview(review),
                                              )
                                              : null,
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
