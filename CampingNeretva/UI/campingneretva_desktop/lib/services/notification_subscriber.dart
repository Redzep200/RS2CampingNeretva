// lib/services/notification_subscriber.dart

import 'dart:convert';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationSubscriber {
  static Client? _client;
  static Channel? _channel;
  static Consumer? _consumer;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    _isInitialized = true;

    print("Starting real-time AI notifications...");

    // === 1. Initialize local notifications (popup) ===
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && context.mounted) {
          Navigator.of(context).pushNamed('/notifications');
        }
      },
    );

    // === 2. Connect to RabbitMQ ===
    final String host = dotenv.env['RABBITMQ_HOST'] ?? 'host.docker.internal';

    final ConnectionSettings connectionSettings = ConnectionSettings(
      host: host,
      port: 5672,
      authProvider: const PlainAuthenticator('guest', 'guest'),
    );

    try {
      _client = Client(settings: connectionSettings);
      _channel = await _client!.channel();

      final Queue queue = await _channel!.queue(
        "activity_comment_notifications",
        durable: true,
      );

      // CORRECT WAY for dart_amqp 0.3.1+
      _consumer = await queue.consume(consumerTag: "admin_desktop");

      print("Connected to RabbitMQ. Listening for AI alerts...");

      _consumer!.listen((message) {
        try {
          final String body = utf8.decode(message.payload!);
          final Map<String, dynamic> data = jsonDecode(body);

          final String activityName = _extractActivityName(data);
          final String category = data['category']?.toString() ?? "Issue";
          final String summary =
              data['summary']?.toString() ?? "New feedback detected";

          _showNotification(context, activityName, category, summary);

          message.ack();
        } catch (e) {
          print("Failed to process RabbitMQ message: $e");
          message.ack();
        }
      });
    } catch (e) {
      print("RabbitMQ connection failed: $e");
      _isInitialized = false;
      Future.delayed(const Duration(seconds: 15), () {
        if (context.mounted) initialize(context);
      });
    }
  }

  static String _extractActivityName(Map<String, dynamic> data) {
    if (data['activity'] is Map && data['activity']['name'] != null) {
      return data['activity']['name'];
    }
    if (data['activityName'] != null) return data['activityName'];
    if (data['Activity']?['Name'] != null) return data['Activity']['Name'];
    return "Unknown Activity";
  }

  static Future<void> _showNotification(
    BuildContext context,
    String activityName,
    String category,
    String summary,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'ai_alerts',
          'AI Feedback Alerts',
          channelDescription: 'AI detected customer issues',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "AI Alert: $activityName",
      "$category → $summary",
      details,
      payload: "open_notifications",
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 10),
          content: Text("AI Alert: $activityName – $category issue!"),
          action: SnackBarAction(
            label: "OPEN",
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ),
      );
    }
  }

  static void dispose() {
    _consumer?.cancel();
    _client?.close();
  }
}
