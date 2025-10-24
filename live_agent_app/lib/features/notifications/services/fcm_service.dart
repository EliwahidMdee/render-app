import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

// Top-level function for background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Background message: ${message.data}');
}

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final DioClient _dioClient;
  final SecureStorage _storage;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FCMService(this._dioClient, this._storage);

  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('FCM permission granted');
      } else {
        AppLogger.warning('FCM permission denied');
        return;
      }

      // Get FCM token
      final token = await _fcm.getToken();
      if (token != null) {
        await _storage.write(AppConstants.fcmTokenKey, token);
        await _updateAgentStatus(token, true);
        AppLogger.info('FCM token obtained: ${token.substring(0, 20)}...');
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) async {
        await _storage.write(AppConstants.fcmTokenKey, newToken);
        await _updateAgentStatus(newToken, true);
        AppLogger.info('FCM token refreshed');
      });

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle notification tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check for initial message (app opened from notification)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      AppLogger.info('FCM service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize FCM', e);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap from local notification
        AppLogger.info('Local notification tapped: ${details.payload}');
      },
    );
  }

  Future<void> _updateAgentStatus(String fcmToken, bool isOnline) async {
    try {
      await _dioClient.dio.put(
        '/api/v1/live-agent/agent/status',
        data: {
          'is_online': isOnline,
          'fcm_token': fcmToken,
        },
      );
      AppLogger.info('Agent status updated: ${isOnline ? 'online' : 'offline'}');
    } catch (e) {
      AppLogger.error('Failed to update agent status', e);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground message: ${message.data}');

    // Show local notification
    _showLocalNotification(message);

    // Handle different notification types
    final type = message.data['type'];
    if (type == 'new_session') {
      // Refresh sessions list - handled by app
      AppLogger.info('New session notification');
    } else if (type == 'new_message') {
      // Update chat if open - handled by app
      AppLogger.info('New message notification');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    final sessionId = message.data['session_id'];

    AppLogger.info('Notification tapped - Type: $type, SessionId: $sessionId');

    if (type == 'new_session' || type == 'new_message') {
      // Navigate to chat screen - handled by app navigation
      // This should trigger a navigation event that the app listens to
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'live_agent_channel',
      'Live Agent',
      channelDescription: 'Live agent notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      details,
      payload: message.data['session_id'],
    );
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    final fcmToken = await _storage.read(AppConstants.fcmTokenKey);
    if (fcmToken != null) {
      await _updateAgentStatus(fcmToken, isOnline);
    } else {
      AppLogger.warning('FCM token not found, cannot update online status');
    }
  }

  Future<void> dispose() async {
    await setOnlineStatus(false);
  }
}
