import 'package:flutter/material.dart';
import 'dart:async';
import '../services/activity_analysis_service.dart';
import '../models/activity_comment_notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Timer? _checkTimer;
  int _lastKnownCount = 0;
  final _notificationController =
      StreamController<CommentAnalysisResult>.broadcast();

  Stream<CommentAnalysisResult> get notificationStream =>
      _notificationController.stream;

  void startMonitoring() {
    // Check for new notifications every 60 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      try {
        final notifications = await ActivityAnalysisService.getNotifications();
        final count = notifications.length;

        // If count increased, fetch and show new notifications
        if (count > _lastKnownCount) {
          final notifications =
              await ActivityAnalysisService.getNotifications();

          // Get only the new ones (simple approach: just show the first new one)
          if (notifications.isNotEmpty) {
            _notificationController.add(notifications.first);
          }
        }

        _lastKnownCount = count;
      } catch (e) {
        print('Error checking notifications: $e');
      }
    });
  }

  void stopMonitoring() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  void dispose() {
    stopMonitoring();
    _notificationController.close();
  }
}

class NotificationOverlay extends StatefulWidget {
  final Widget child;

  const NotificationOverlay({super.key, required this.child});

  @override
  State<NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<NotificationOverlay> {
  final List<CommentAnalysisResult> _activeNotifications = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    NotificationService().startMonitoring();

    _subscription = NotificationService().notificationStream.listen((
      notification,
    ) {
      setState(() {
        _activeNotifications.add(notification);
      });

      // Auto-remove after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _activeNotifications.remove(notification);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _dismissNotification(CommentAnalysisResult notification) {
    setState(() {
      _activeNotifications.remove(notification);
    });
  }

  void _navigateToNotifications(CommentAnalysisResult notification) {
    _dismissNotification(notification);
    Navigator.pushNamed(context, '/notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Notification toasts
        Positioned(
          top: 80,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                _activeNotifications.map((notification) {
                  return _buildNotificationToast(notification);
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToast(CommentAnalysisResult notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: 400,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          onTap: () => _navigateToNotifications(notification),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: _getCategoryColor(notification.category),
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: _getCategoryColor(notification.category),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Activity Needs Attention',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _dismissNotification(notification),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.activityName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${notification.category} issue - ${notification.relatedComments.length} negative comments',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.aiSummary.length > 100
                      ? '${notification.aiSummary.substring(0, 100)}...'
                      : notification.aiSummary,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _navigateToNotifications(notification),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
