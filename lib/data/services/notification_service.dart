import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    if (!_supportsSystemNotifications) {
      _isInitialized = true;
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(settings);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  Future<void> showWorkoutCompleteAlert({
    required String workoutName,
    required String stats,
    required String? title,
    required String? body,
  }) async {
    if (!_supportsSystemNotifications) {
      return;
    }

    await _plugin.show(
      workoutName.hashCode,
      title ?? _buildWorkoutTitle(),
      body ?? stats,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_complete',
          'Workout Completion',
          channelDescription: 'High priority workout completion notifications.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showReminderNotification({
    required String title,
    required String body,
  }) async {
    if (!_supportsSystemNotifications) {
      return;
    }

    await _plugin.show(
      title.hashCode ^ body.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Reminders',
          channelDescription: 'General reminder notifications.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  String buildWorkoutTitle({bool isFirstWorkoutOfDay = false}) {
    if (isFirstWorkoutOfDay) {
      return 'First Workout Done!';
    }
    return _buildWorkoutTitle();
  }

  String buildWorkoutBody({
    required String workoutName,
    required double distanceMeters,
    required int elapsedSeconds,
    String? paceText,
  }) {
    final distanceKm = distanceMeters / 1000;
    final durationText = _formatDuration(elapsedSeconds);

    if (distanceKm > 5) {
      return 'Amazing endurance! You covered ${distanceKm.toStringAsFixed(1)} km in $durationText.';
    }
    if (distanceKm > 2) {
      final paceSuffix = (paceText == null || paceText == '--')
          ? ''
          : ' at $paceText pace';
      return 'Solid run! ${distanceKm.toStringAsFixed(1)} km$paceSuffix.';
    }
    if (distanceMeters > 0) {
      return 'Every step counts! You ran ${distanceKm.toStringAsFixed(1)} km today.';
    }
    if (elapsedSeconds > 1800) {
      return '30+ minutes of work! $workoutName is done.';
    }
    return '$workoutName complete! Keep the streak alive.';
  }

  String _buildWorkoutTitle() {
    return 'Workout Complete!';
  }

  String _formatDuration(int elapsedSeconds) {
    final duration = Duration(seconds: elapsedSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  bool get _supportsSystemNotifications {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
