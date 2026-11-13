import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Receives FCM notifications and registers the device for test delivery.
///
/// firebase_messaging 17 uses Firebase Installation IDs rather than legacy
/// registration tokens. The Android manifest must enable FID registration.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _registrationSubscription;

  /// Available asynchronously from onRegistered after successful registration.
  String? installationId;

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

    // Listen BEFORE calling register() so registration events are not missed.
    _registrationSubscription ??= _messaging.onRegistered.listen((id) {
      installationId = id;
      // Only print during development. Treat device identifiers as private.
      if (kDebugMode) debugPrint('Chapter FCM installation ID: $id');
    });

    // A notification could have launched the app from a terminated state.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) onOpenedMessage(initialMessage);

    // Do not prompt at launch: permissions are requested from the UI button.
    final settings = await _messaging.getNotificationSettings();
    if (_isAllowed(settings.authorizationStatus)) {
      await registerDevice();
    }
  }

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (_isAllowed(settings.authorizationStatus)) {
      await registerDevice();
    }
    return settings.authorizationStatus;
  }

  bool _isAllowed(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  Future<void> registerDevice() async {
    // APNs registration is required before Firebase Messaging registration
    // on Apple platforms. This project is tested on Android first.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        if (kDebugMode) debugPrint('Chapter FCM: waiting for APNs token');
        return;
      }
    }
    try {
      await _messaging.register();
      // The ID is sent asynchronously to onRegistered (listener above).
    } catch (error) {
      if (kDebugMode) debugPrint('Chapter FCM registration failed: $error');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _registrationSubscription?.cancel();
    _foregroundSubscription = null;
    _openedSubscription = null;
    _registrationSubscription = null;
  }
}
