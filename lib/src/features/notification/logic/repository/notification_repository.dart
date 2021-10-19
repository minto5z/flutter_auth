import 'package:auth/src/features/messages/views/screens/direct_message_screen.dart';
import 'package:auth/src/features/notification/logic/enums/notification_type.dart';
import 'package:auth/src/features/notification/logic/repository/subscription_repository.dart';
import 'package:auth/src/features/room/views/screens/room_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationRepository {
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  final subscriptionRepository = SubscriptionRepository();

  Future<void> setup() async {
    await Firebase.initializeApp();

    _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> init(BuildContext context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleBackgroundMessage(context, initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleBackgroundMessage(context, message),
    );

    FirebaseMessaging.onMessage.listen(
      (message) => _handleForegroundMessage(context, message),
    );
  }

  void _handleForegroundMessage(BuildContext context, RemoteMessage message) {
    final type = message.data['type'];

    SnackBar? snackBar;

    if (type == NotificationType.room.name) {
      snackBar = SnackBar(
        content: Text(
          'Message received from Room: ${message.data['title']}',
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _redirectToRoom(
            context,
            message.data['roomId'],
          ),
        ),
      );
    }

    if (type == NotificationType.direct.name) {
      snackBar = SnackBar(
        content: Text(
          'Message received from User: ${message.data['username']}',
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _redirectToUser(
            context,
            message.data['username'],
          ),
        ),
      );
    }

    if (snackBar == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleBackgroundMessage(BuildContext context, RemoteMessage message) {
    final type = message.data['type'];

    if (type == NotificationType.room.name) {
      _redirectToRoom(context, message.data['roomId']);
    }

    if (type == NotificationType.direct.name) {
      _redirectToUser(context, message.data['username']);
    }
  }

  _redirectToUser(BuildContext context, String username) {
    Navigator.pushNamed(
      context,
      DirectMessageScreen.routeName,
      arguments: DirectMessageArguments(
        username: username,
      ),
    );
  }

  _redirectToRoom(BuildContext context, String roomId) {
    Navigator.pushNamed(
      context,
      RoomScreen.routeName,
      arguments: roomId,
    );
  }

  Future<void> requestPermission() async {
    await _fcm.requestPermission();

    final token = await _fcm.getToken();

    if (token == null) {
      return;
    }

    await subscriptionRepository.registerSubscription(token);
  }

  Future<void> deleteSubscription() async {
    final token = await _fcm.getToken();

    if (token == null) {
      return;
    }

    return subscriptionRepository.deleteSubscription(token);
  }
}

final notificationRepository = NotificationRepository();
