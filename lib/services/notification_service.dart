import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../core/constants/app_constants.dart';
import 'supabase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _canScheduleExact = false;

  /// Dedicated notification small icon — must be a flat PNG or vector drawable,
  /// NOT an adaptive icon XML. Adaptive icons silently fail on Android 8+.
  static const String _notificationIcon =
      '@drawable/ic_stat_plant_notification';

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone database
      tz_data.initializeTimeZones();

      // Set local timezone properly
      _setupTimezone();

      // Use a proper drawable icon (NOT @mipmap/ic_launcher which is adaptive XML)
      const androidSettings = AndroidInitializationSettings(_notificationIcon);
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initializationResult = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      debugPrint(
          '🔔 Notification initialization result: $initializationResult');

      // Create high-importance notification channel
      const androidChannel = AndroidNotificationChannel(
        AppConstants.reminderChannelId,
        AppConstants.reminderChannelName,
        description: AppConstants.reminderChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      final androidImpl = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        // Delete the old channel if it exists (to pick up new settings)
        await androidImpl
            .deleteNotificationChannel(AppConstants.reminderChannelId);
        debugPrint('🗑️ Deleted old notification channel (if existed)');

        await androidImpl.createNotificationChannel(androidChannel);
        debugPrint(
            '✅ Notification channel created: ${AppConstants.reminderChannelName}');

        // Request notification permission (Android 13+)
        final granted = await androidImpl.requestNotificationsPermission();
        debugPrint('📱 Notification permission granted: $granted');

        // Request exact alarm permission (Android 12+) and check result
        try {
          await androidImpl.requestExactAlarmsPermission();
        } catch (_) {}

        // Check if we can actually schedule exact alarms
        try {
          final canExact =
              await androidImpl.canScheduleExactNotifications() ?? false;
          _canScheduleExact = canExact;
          debugPrint('⏰ Can schedule exact alarms: $_canScheduleExact');
        } catch (e) {
          _canScheduleExact = false;
          debugPrint('⚠️ Cannot check exact alarm capability: $e');
        }
      } else {
        debugPrint('⚠️ Android implementation not available');
      }

      _initialized = true;
      debugPrint('✅ Notification service initialized successfully');
      debugPrint('   Exact alarm mode: $_canScheduleExact');
    } catch (e, stackTrace) {
      debugPrint('Notification initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      _initialized = false;
    }
  }

  /// Setup timezone correctly for the device
  void _setupTimezone() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      final offsetHours = offset.inHours;
      final offsetMinutes = offset.inMinutes.remainder(60);

      debugPrint(
          '📍 Device timezone offset: UTC${offsetHours >= 0 ? '+' : ''}$offsetHours:${offsetMinutes.abs().toString().padLeft(2, '0')}');

      // Try common timezone names first based on offset
      // Egypt is UTC+2, so default to Africa/Cairo for this app
      final knownTimezones = <int, String>{
        2: 'Africa/Cairo',
        3: 'Asia/Riyadh',
        4: 'Asia/Dubai',
        5: 'Asia/Karachi',
        1: 'Europe/London',
        0: 'UTC',
        -5: 'America/New_York',
        -6: 'America/Chicago',
        -7: 'America/Denver',
        -8: 'America/Los_Angeles',
      };

      String? tzName = knownTimezones[offsetHours];

      if (tzName != null) {
        try {
          tz.setLocalLocation(tz.getLocation(tzName));
          debugPrint('✅ Timezone set to: $tzName');
          return;
        } catch (e) {
          debugPrint('⚠️ Could not set timezone $tzName: $e');
        }
      }

      // Fallback: use Etc/GMT with INVERTED sign (Etc/GMT convention)
      if (offsetHours == 0 && offsetMinutes == 0) {
        tz.setLocalLocation(tz.getLocation('UTC'));
        debugPrint('✅ Timezone set to: UTC');
      } else {
        // IMPORTANT: Etc/GMT sign is INVERTED compared to UTC offset
        final etcSign = offsetHours > 0 ? '-' : '+';
        final absHours = offsetHours.abs();
        final etcTzName = 'Etc/GMT$etcSign$absHours';
        try {
          tz.setLocalLocation(tz.getLocation(etcTzName));
          debugPrint('✅ Timezone set to: $etcTzName');
        } catch (e) {
          tz.setLocalLocation(tz.getLocation('UTC'));
          debugPrint('⚠️ Using UTC as fallback: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Timezone setup error: $e');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
  }

  /// Determine the best AndroidScheduleMode based on device capabilities
  AndroidScheduleMode get _bestScheduleMode {
    if (_canScheduleExact) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    // Fallback: inexactAllowWhileIdle works without SCHEDULE_EXACT_ALARM permission
    // Notifications will still fire, possibly with a few minutes delay
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Build Android notification details with the proper small icon
  AndroidNotificationDetails _buildAndroidDetails() {
    return const AndroidNotificationDetails(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      channelDescription: AppConstants.reminderChannelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      icon: _notificationIcon,
    );
  }

  Future<int> scheduleReminder({
    required String title,
    required TimeOfDay time,
    required String repeat,
    String? tips,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();

    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now) ||
        scheduledDate.difference(now).inSeconds < 10) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      debugPrint('⏰ Scheduled time is in the past, moving to tomorrow');
    }

    tz.Location location = _getLocation();

    final tzScheduledDate = tz.TZDateTime(
      location,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    final tzNow = tz.TZDateTime.now(location);
    var timeUntil = tzScheduledDate.difference(tzNow);

    tz.TZDateTime finalScheduledDate = tzScheduledDate;
    if (timeUntil.isNegative || timeUntil.inSeconds < 10) {
      finalScheduledDate = tz.TZDateTime(
        location,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day + 1,
        scheduledDate.hour,
        scheduledDate.minute,
      );
      timeUntil = finalScheduledDate.difference(tzNow);
      debugPrint('   Rescheduling for tomorrow: $finalScheduledDate');
    }

    debugPrint('📅 Scheduling reminder:');
    debugPrint('   Title: $title');
    debugPrint(
        '   Time: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
    debugPrint('   Repeat: $repeat');
    debugPrint(
        '   Will trigger in: ${timeUntil.inHours}h ${timeUntil.inMinutes.remainder(60)}m');
    debugPrint('   Schedule mode: $_bestScheduleMode');
    debugPrint('   Can use exact alarms: $_canScheduleExact');

    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    String body = 'Time to care for your plants! 🌱';
    if (tips != null && tips.isNotEmpty) {
      body = '💡 Tip: $tips';
    }

    final androidDetails = _buildAndroidDetails();

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduleMode = _bestScheduleMode;

    try {
      if (repeat == 'Once') {
        await _notifications.zonedSchedule(
          notificationId,
          '🌿 $title',
          body,
          finalScheduledDate,
          notificationDetails,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else if (repeat == 'Daily') {
        await _notifications.zonedSchedule(
          notificationId,
          '🌿 $title',
          body,
          finalScheduledDate,
          notificationDetails,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else if (repeat == 'Weekly') {
        await _notifications.zonedSchedule(
          notificationId,
          '🌿 $title',
          body,
          finalScheduledDate,
          notificationDetails,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }

      debugPrint('✅ Notification scheduled ($repeat) with ID: $notificationId');

      // Verify the notification is in the pending list
      final pending = await _notifications.pendingNotificationRequests();
      final scheduled =
          pending.where((n) => n.id == notificationId).isNotEmpty;
      debugPrint('   Verified in pending list: $scheduled');
      debugPrint('   Total pending: ${pending.length}');

      // If NOT in pending list, the schedule silently failed — try inexact fallback
      if (!scheduled) {
        debugPrint(
            '⚠️ Notification NOT in pending list! Trying inexact fallback...');
        await _scheduleWithInexactFallback(
          notificationId: notificationId,
          title: '🌿 $title',
          body: body,
          scheduledDate: finalScheduledDate,
          notificationDetails: notificationDetails,
          repeat: repeat,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error scheduling notification: $e');
      debugPrint('   Stack trace: $stackTrace');

      // Try inexact fallback
      try {
        await _scheduleWithInexactFallback(
          notificationId: notificationId,
          title: '🌿 $title',
          body: body,
          scheduledDate: finalScheduledDate,
          notificationDetails: notificationDetails,
          repeat: repeat,
        );
      } catch (fallbackError) {
        debugPrint('❌ Inexact fallback also failed: $fallbackError');
        // Last resort: show immediately
        try {
          await _notifications.show(
            notificationId,
            '🌿 $title',
            '$body\n⚠️ Scheduling failed - showing now instead.',
            notificationDetails,
          );
        } catch (_) {}
      }
    }

    return notificationId;
  }

  /// Fallback scheduling using inexactAllowWhileIdle
  Future<void> _scheduleWithInexactFallback({
    required int notificationId,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required String repeat,
  }) async {
    debugPrint('🔄 Using inexactAllowWhileIdle fallback...');

    DateTimeComponents? matchComponents;
    if (repeat == 'Daily') {
      matchComponents = DateTimeComponents.time;
    } else if (repeat == 'Weekly') {
      matchComponents = DateTimeComponents.dayOfWeekAndTime;
    }

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchComponents,
    );

    final pending = await _notifications.pendingNotificationRequests();
    final found = pending.where((n) => n.id == notificationId).isNotEmpty;
    debugPrint('   Inexact fallback result - in pending: $found');
    debugPrint('   Total pending: ${pending.length}');
  }

  tz.Location _getLocation() {
    try {
      return tz.local;
    } catch (e) {
      debugPrint('⚠️ Error getting local timezone: $e');
      _setupTimezone();
      return tz.local;
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Show an immediate notification right now (for testing)
  Future<void> showImmediateNotification({
    String title = 'Plant Care Reminder',
    String body = 'This is a test notification!',
  }) async {
    if (!_initialized) await initialize();

    final androidDetails = _buildAndroidDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
      );
      debugPrint('✅ Immediate notification shown: $title');
    } catch (e, stackTrace) {
      debugPrint('❌ Error showing immediate notification: $e');
      debugPrint('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> testNotification() async {
    if (!_initialized) await initialize();

    debugPrint('🧪 ====== TESTING NOTIFICATIONS ======');
    debugPrint('   Initialized: $_initialized');
    debugPrint('   Can schedule exact: $_canScheduleExact');
    debugPrint('   Best schedule mode: $_bestScheduleMode');

    final androidDetails = _buildAndroidDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // STEP 1: Show an immediate notification (should appear instantly)
    try {
      debugPrint('📤 Step 1: Sending immediate notification...');
      await _notifications.show(
        99998,
        '🌿 Test: Immediate ✅',
        'This appeared immediately. Notifications work!',
        notificationDetails,
      );
      debugPrint('✅ Immediate notification sent!');
    } catch (e, stackTrace) {
      debugPrint('❌ Immediate notification failed: $e');
      debugPrint('   Stack trace: $stackTrace');
    }

    // STEP 2: Schedule with inexactAllowWhileIdle (most reliable, no special permissions)
    try {
      final location = _getLocation();
      final now = tz.TZDateTime.now(location);
      final testTime = now.add(const Duration(seconds: 10));

      debugPrint(
          '📅 Step 2: Scheduling with INEXACT mode for: $testTime (10 sec)');
      debugPrint('   Current TZ time: $now');
      debugPrint('   Timezone: ${location.name}');

      await _notifications.zonedSchedule(
        99997,
        '🌿 Test: Scheduled (inexact) ⏰',
        'This was scheduled 10 seconds ago using inexact mode. It works!',
        testTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      final pending = await _notifications.pendingNotificationRequests();
      final found = pending.where((n) => n.id == 99997).isNotEmpty;
      debugPrint('   In pending list: $found');
      debugPrint('   Total pending: ${pending.length}');

      if (!found) {
        debugPrint('⚠️ NOT in pending list even with inexact mode!');
        // Last resort: use a Dart Timer to show after delay
        debugPrint('🔄 Using Dart Timer fallback (10 seconds)...');
        Timer(const Duration(seconds: 10), () async {
          try {
            await _notifications.show(
              99996,
              '🌿 Test: Timer Fallback ⏰',
              'This was triggered using a Dart Timer (app must be running).',
              notificationDetails,
            );
            debugPrint('✅ Timer fallback notification shown!');
          } catch (e) {
            debugPrint('❌ Timer fallback failed: $e');
          }
        });
        debugPrint('   Timer set! Will fire in 10 seconds.');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Scheduled notification failed: $e');
      debugPrint('   Stack trace: $stackTrace');

      // Use Dart Timer as ultimate fallback
      debugPrint('🔄 Using Dart Timer as ultimate fallback...');
      Timer(const Duration(seconds: 10), () async {
        try {
          await _notifications.show(
            99995,
            '🌿 Test: Timer Fallback ⏰',
            'zonedSchedule failed. This was triggered using a Dart Timer.',
            notificationDetails,
          );
        } catch (e) {
          debugPrint('❌ Timer fallback failed too: $e');
        }
      });
    }

    debugPrint('🧪 ====== TEST COMPLETE ======');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<AndroidFlutterLocalNotificationsPlugin?>
      getAndroidImplementation() async {
    return _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
  }

  Future<void> rescheduleAllReminders() async {
    if (!_initialized) await initialize();

    try {
      debugPrint('🔄 Rescheduling all reminders from database...');

      final reminders = await SupabaseService.instance.getReminders();

      debugPrint('📋 Found ${reminders.length} reminders in database');

      // Cancel all existing scheduled notifications first to avoid duplicates
      await cancelAllNotifications();
      debugPrint('🗑️ Cleared all existing scheduled notifications');

      for (var reminder in reminders) {
        try {
          // Only reschedule active reminders
          if (reminder['is_active'] != true) {
            debugPrint(
                '⏭️ Skipping inactive reminder: ${reminder['title']}');
            continue;
          }

          final title = reminder['title'] as String;
          final scheduledTime = reminder['scheduled_time'] as String;
          final repeat = reminder['repeat_frequency'] as String? ?? 'Daily';
          final tips = reminder['tips'] as String?;

          final timeParts = scheduledTime.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final time = TimeOfDay(hour: hour, minute: minute);

          final notificationId = await scheduleReminder(
            title: title,
            time: time,
            repeat: repeat,
            tips: tips,
          );

          await SupabaseService.instance.updateReminderNotificationId(
            reminder['id'] as String,
            notificationId,
          );

          debugPrint(
              '✅ Rescheduled: $title at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
        } catch (e) {
          debugPrint(
              '❌ Error rescheduling reminder ${reminder['id']}: $e');
        }
      }

      final pending = await getPendingNotifications();
      debugPrint(
          '✅ Finished rescheduling. Total pending: ${pending.length}');
    } catch (e) {
      debugPrint('❌ Error rescheduling reminders: $e');
    }
  }
}
