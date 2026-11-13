import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Minimal Firebase Cloud Messaging integration for Chapter.
///
/// FCM sends notification messages to the OS in the background. While Chapter
/// is foregrounded, the app displays the message using its ScaffoldMessenger.
/// For a demo, the Firebase Console can send a test message to [token].
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;

  String? token;

  Future<void> initialize({
    required void Function(RemoteMessage message) onForegroundMessage,
    required void Function(RemoteMessage message) onOpenedMessage,
  }) async {
    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen(
      onForegroundMessage,
    );
    _openedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(
      onOpenedMessage,
    );
    _tokenSubscription ??= _messaging.onTokenRefresh.listen((newToken) {
      token = newToken;
      if (kDebugMode) debugPrint('Chapter FCM token refreshed: $newToken');
    });

    // A notification could have launched Chapter from a terminated state.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) onOpenedMessage(initialMessage);

    // Do not show an OS permission prompt until the user taps the button.
    final settings = await _messaging.getNotificationSettings();
    if (_isAllowed(settings.authorizationStatus)) {
      await refreshToken();
    }
  }

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (_isAllowed(settings.authorizationStatus)) {
      await refreshToken();
    }
    return settings.authorizationStatus;
  }

  bool _isAllowed(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  Future<String?> refreshToken() async {
    try {
      // On Apple platforms, APNs registration may take a moment to complete.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          if (kDebugMode) debugPrint('Chapter FCM: waiting for APNs token');
          return null;
        }
      }
      token = await _messaging.getToken();
      // Printed only during development so Firebase Console can target this
      // device for a test message. Do not log registration tokens in production.
      if (kDebugMode) debugPrint('Chapter FCM test token: $token');
      return token;
    } catch (e) {
      if (kDebugMode) debugPrint('Chapter FCM token unavailable: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();
    _foregroundSubscription = null;
    _openedSubscription = null;
    _tokenSubscription = null;
  }
}
