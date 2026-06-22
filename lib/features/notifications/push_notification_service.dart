import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/router/app_router.dart';

/// Wraps FCM: permission, token registration, and routing a tapped invite
/// notification to the Invites inbox. Notification *display* is handled by the
/// OS (we send `notification` payloads); this only manages tokens + taps.
class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    FirebaseFunctions? functions,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: kCloudFunctionsRegion);

  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;

  bool _registered = false;

  /// One-time setup: show foreground banners, route notification taps, and keep
  /// the stored token fresh. Safe to call before sign-in.
  Future<void> initialize() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleTap(initial);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    _messaging.onTokenRefresh.listen(_saveToken);
  }

  /// After sign-in: request permission and register this device's token.
  Future<void> registerForUser() async {
    if (_registered) return;

    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _saveToken(token);
    _registered = true;
  }

  /// On sign-out: invalidate the token so this device stops receiving the
  /// user's pushes. The backend prunes the dead token on its next send.
  Future<void> clearForUser() async {
    _registered = false;
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // Best effort — a failed delete just leaves a token the backend prunes.
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      await _functions.httpsCallable('registerDeviceToken').call(<String, dynamic>{
        'token': token,
      });
    } catch (_) {
      // Non-fatal: token registration retries on the next refresh / launch.
    }
  }

  void _handleTap(RemoteMessage message) {
    if (message.data['type'] == 'invite') {
      appRouter.go(AppRoutes.invites);
    }
  }
}
