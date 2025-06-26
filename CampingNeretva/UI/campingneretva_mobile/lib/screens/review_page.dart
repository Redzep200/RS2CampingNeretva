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

  Map<int, Review> userReviewsByWorker = {};
  int _currentPage = 0;
  final int _pageSize = 4;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);

    try {
      workers = await WorkerService.getAll();
      reviews = await ReviewService.getAll(
        page: _currentPage,
        pageSize: _pageSize,
      );
      await _loadUserReviewMap();
    } catch (e) {
      errorMessage = 'Failed to load data: $e';
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadReviewsForWorker() async {
    setState(() => isLoading = true);

    try {
      reviews = await ReviewService.getAll(
        workerId: selectedWorker?.id,
        page: _currentPage,
        pageSize: _pageSize,
      );
      await _loadUserReviewMap();
    } catch (e) {
      errorMessage = 'Failed to load reviews: $e';
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadUserReviewMap() async {
    final user = AuthService.currentUser;
    userReviewsByWorker.clear();

    if (user != null) {
      for (var review in reviews) {
        if (review.user.id == user.id) {
          userReviewsByWorker[review.worker.id] = review;
        }
      }
    }

    reviews.sort((a, b) {
      if (user != null) {
        bool isAUserReview = a.user.id == user.id;
        bool isBUserReview = b.user.id == user.id;
        if (isAUserReview && !isBUserReview) return -1;
        if (!isAUserReview && isBUserReview) return 1;
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

    setState(() => isLoading = true);

    try {
      final existingReview = userReviewsByWorker[selectedWorker!.id];

      if (existingReview != null) {
        await ReviewService.update(
          reviewId: existingReview.id,
          rating: rating,
          comment: _commentController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review updated successfully')),
        );
      } else {
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
      _currentPage = 0;
      await _loadReviewsForWorker();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _editReview(Review review) {
    setState(() {
      selectedWorker = review.worker;
      rating = review.rating;
      _commentController.text = review.comment;
      _currentPage = 0;
    });
    _loadReviewsForWorker();
  }

  double _calculateAverageRating() {
    if (selectedWorker == null) return 0;
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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<Worker>(
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
                              setState(() {
                                selectedWorker = value;
                                _currentPage = 0;
                              });
                              await _loadReviewsForWorker();
                            },
                          ),
                        ),
                        if (selectedWorker != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () async {
                              setState(() {
                                selectedWorker = null;
                                _currentPage = 0;
                              });
                              await _loadReviewsForWorker();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

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
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    const SizedBox(height: 16),

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

                    if (reviews.isEmpty)
                      const Center(child: Text('No reviews yet'))
                    else
                      Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Posted: ${review.datePosted}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed:
                                      _currentPage > 0
                                          ? () {
                                            setState(() {
                                              _currentPage--;
                                              selectedWorker == null
                                                  ? _loadInitialData()
                                                  : _loadReviewsForWorker();
                                            });
                                          }
                                          : null,
                                  child: const Text('Previous'),
                                ),
                                Text('Page ${_currentPage + 1}'),
                                ElevatedButton(
                                  onPressed:
                                      reviews.length == _pageSize
                                          ? () {
                                            setState(() {
                                              _currentPage++;
                                              selectedWorker == null
                                                  ? _loadInitialData()
                                                  : _loadReviewsForWorker();
                                            });
                                          }
                                          : null,
                                  child: const Text('Next'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}
