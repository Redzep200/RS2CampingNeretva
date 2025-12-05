import 'package:flutter/material.dart';
import '../models/activity_comment_notification_model.dart';
import '../services/activity_analysis_service.dart';
import '../widgets/navbar.dart';
import '../widgets/app_theme.dart';
import 'package:intl/intl.dart';

class ActivityNotificationsPage extends StatefulWidget {
  const ActivityNotificationsPage({super.key});

  @override
  State<ActivityNotificationsPage> createState() =>
      _ActivityNotificationsPageState();
}

class _ActivityNotificationsPageState extends State<ActivityNotificationsPage> {
  List<CommentAnalysisResult> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await ActivityAnalysisService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerAnalysis() async {
    try {
      await ActivityAnalysisService.triggerAnalysis();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis triggered successfully'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to trigger analysis: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'price':
        return Colors.orange;
      case 'staff':
        return Colors.blue;
      case 'time':
        return Colors.purple;
      case 'quality':
        return Colors.red;
      case 'safety':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'price':
        return Icons.attach_money;
      case 'staff':
        return Icons.people;
      case 'time':
        return Icons.schedule;
      case 'quality':
        return Icons.star;
      case 'safety':
        return Icons.security;
      default:
        return Icons.info;
    }
  }

  void _showNotificationDetails(CommentAnalysisResult notification) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: 700,
              constraints: const BoxConstraints(maxHeight: 600),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(notification.category),
                        color: _getCategoryColor(notification.category),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.activityName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${notification.category} Issue',
                              style: TextStyle(
                                fontSize: 14,
                                color: _getCategoryColor(notification.category),
                              ),
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
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Analysis Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notification.aiSummary,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Related Comments (${notification.relatedComments.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: notification.relatedComments.length,
                      itemBuilder: (context, index) {
                        final comment = notification.relatedComments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getRatingColor(comment.rating),
                              child: Text(
                                '${comment.rating}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(comment.commentText),
                            subtitle: Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(comment.datePosted),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: AppTheme.greenTextButtonStyle,
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to activity edit page
                          Navigator.pushNamed(
                            context,
                            '/activities',
                            arguments: notification.activityId,
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Activity'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await ActivityAnalysisService.markAsRead(
                              notification.activityId,
                            ); // Pass actual notification ID
                            Navigator.pop(context);
                            _loadNotifications(); // Refresh list
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Marked as read')),
                            );
                          } catch (e) {
                            // Handle error
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Mark as Read'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating <= 2) return Colors.red;
    if (rating == 3) return Colors.orange;
    return Colors.green;
  }

  Widget _buildNotificationCard(CommentAnalysisResult notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showNotificationDetails(notification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    notification.category,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(notification.category),
                  color: _getCategoryColor(notification.category),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.activityName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${notification.category} - ${notification.relatedComments.length} negative comments',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.aiSummary.length > 150
                          ? '${notification.aiSummary.substring(0, 150)}...'
                          : notification.aiSummary,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'AI-analyzed customer feedback requiring attention',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: AppTheme.greenIconButtonStyle,
                    onPressed: _triggerAnalysis,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Run Analysis'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: AppTheme.greenIconButtonStyle,
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadNotifications,
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: $_errorMessage',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadNotifications,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                      : _notifications.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No pending notifications',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'All activity feedback has been addressed!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(_notifications[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
