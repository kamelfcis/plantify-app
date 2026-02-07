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

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone database
      tz_data.initializeTimeZones();
      
      final timeZoneName = DateTime.now().timeZoneName;
      debugPrint('🌍 Device timezone: $timeZoneName');
      
      try {
        final offset = DateTime.now().timeZoneOffset;
        final offsetHours = offset.inHours;
        final offsetMinutes = offset.inMinutes.remainder(60);
        
        debugPrint('📍 Device timezone offset: ${offsetHours}h ${offsetMinutes}m');
        
        String? tzName;
        if (offsetHours == 0 && offsetMinutes == 0) {
          tzName = 'UTC';
        } else {
          try {
            tz.setLocalLocation(tz.local);
            debugPrint('✅ Using system local timezone: ${tz.local.name}');
          } catch (e) {
            final sign = offsetHours >= 0 ? '+' : '-';
            final absHours = offsetHours.abs();
            tzName = 'Etc/GMT$sign$absHours';
            debugPrint('⚠️ Trying timezone: $tzName');
          }
        }
        
        if (tzName != null) {
          try {
            tz.setLocalLocation(tz.getLocation(tzName));
            debugPrint('✅ Timezone set to: $tzName');
          } catch (e) {
            tz.setLocalLocation(tz.getLocation('UTC'));
            debugPrint('⚠️ Using UTC as fallback: $e');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Timezone setup: $e');
        try {
          tz.setLocalLocation(tz.getLocation('UTC'));
        } catch (_) {}
      }

      const androidSettings = AndroidInitializationSettings('@android:drawable/sym_def_app_icon');
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

      debugPrint('🔔 Notification initialization result: $initializationResult');

      const androidChannel = AndroidNotificationChannel(
        AppConstants.reminderChannelId,
        AppConstants.reminderChannelName,
        description: AppConstants.reminderChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(androidChannel);
        debugPrint('✅ Notification channel created: ${AppConstants.reminderChannelName}');
        
        final granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('📱 Notification permission granted: $granted');
      } else {
        debugPrint('⚠️ Android implementation not available');
      }

      _initialized = true;
      debugPrint('✅ Notification service initialized successfully');
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
      _initialized = false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  Future<int> scheduleReminder({
    required String title,
    required TimeOfDay time,
    required String repeat,
    String? tips,
  }) async {
    if (!_initialized) await initialize();

    try {
      tz_data.initializeTimeZones();
    } catch (e) {
      // Already initialized
    }

    final now = DateTime.now();
    
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      debugPrint('⏰ Scheduled time is in the past, moving to tomorrow');
    }

    tz.Location location;
    try {
      location = tz.local;
      debugPrint('🌍 Using timezone location: ${location.name}');
    } catch (e) {
      debugPrint('⚠️ Error getting local timezone: $e');
      location = tz.getLocation('UTC');
    }
    
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, location);
    
    debugPrint('🕐 Time calculation:');
    debugPrint('   Device local time: $now');
    debugPrint('   Scheduled local time: $scheduledDate');
    debugPrint('   TZ Scheduled time: $tzScheduledDate');
    debugPrint('   Timezone: ${location.name}');
    
    final tzNow = tz.TZDateTime.from(now, location);
    var timeUntil = tzScheduledDate.difference(tzNow);
    
    tz.TZDateTime finalScheduledDate = tzScheduledDate;
    if (timeUntil.isNegative) {
      debugPrint('⚠️ WARNING: Scheduled time is in the past!');
      final tomorrow = scheduledDate.add(const Duration(days: 1));
      finalScheduledDate = tz.TZDateTime.from(tomorrow, location);
      timeUntil = finalScheduledDate.difference(tzNow);
      debugPrint('   Rescheduling for tomorrow: $finalScheduledDate');
    }

    debugPrint('📅 Scheduling reminder:');
    debugPrint('   Title: $title');
    debugPrint('   Time: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
    debugPrint('   Repeat: $repeat');
    debugPrint('   Will trigger in: ${timeUntil.inHours}h ${timeUntil.inMinutes.remainder(60)}m');

    int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    String body = 'Time to care for your plants!';
    if (tips != null && tips.isNotEmpty) {
      body = '💡 Tip: $tips';
    }

    const androidDetails = AndroidNotificationDetails(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      channelDescription: AppConstants.reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    
    if (timeUntil.inMinutes < 1 && timeUntil.inSeconds > 0) {
      debugPrint('⏱️ Scheduling soon (< 1 min), using exactAllowWhileIdle');
      scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    }

    try {
      if (repeat == 'Once') {
        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          finalScheduledDate,
          notificationDetails,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('✅ Notification scheduled (Once) with ID: $notificationId');
      } else if (repeat == 'Daily') {
        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          finalScheduledDate,
          notificationDetails,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint('✅ Notification scheduled (Daily) with ID: $notificationId');
      } else if (repeat == 'Weekly') {
        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          finalScheduledDate,
          notificationDetails,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        debugPrint('✅ Notification scheduled (Weekly) with ID: $notificationId');
      }
      
      final pending = await _notifications.pendingNotificationRequests();
      final scheduled = pending.where((n) => n.id == notificationId).isNotEmpty;
      debugPrint('   Verified in pending list: $scheduled');
      
      debugPrint('📋 All pending notifications (${pending.length} total):');
      for (var notif in pending) {
        debugPrint('   - ID: ${notif.id}, Title: ${notif.title}');
      }
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
      rethrow;
    }

    return notificationId;
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> testNotification() async {
    if (!_initialized) await initialize();

    debugPrint('🧪 Testing notification...');
    debugPrint('   Initialized: $_initialized');

    const androidDetails = AndroidNotificationDetails(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      channelDescription: AppConstants.reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      debugPrint('📤 Attempting immediate notification...');
      await _notifications.show(
        99998,
        'Test Notification (Immediate)',
        'If you see this, notifications are working!',
        notificationDetails,
      );
      debugPrint('✅ Immediate notification sent!');
      return;
    } catch (e) {
      debugPrint('⚠️ Immediate notification failed: $e');
    }

    try {
      final now = DateTime.now();
      final testTime = now.add(const Duration(seconds: 5));
      
      tz.Location location;
      try {
        location = tz.local;
      } catch (e) {
        location = tz.getLocation('UTC');
      }
      
      final tzTestTime = tz.TZDateTime.from(testTime, location);
      
      debugPrint('📅 Scheduling test notification for: $tzTestTime');

      await _notifications.zonedSchedule(
        99999,
        'Test Reminder (Scheduled)',
        'This is a scheduled test notification.',
        tzTestTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ Scheduled test notification!');
    } catch (e) {
      debugPrint('❌ Error with scheduled notification: $e');
      rethrow;
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  
  Future<AndroidFlutterLocalNotificationsPlugin?> getAndroidImplementation() async {
    return _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  }
  
  Future<void> rescheduleAllReminders() async {
    if (!_initialized) await initialize();
    
    try {
      debugPrint('🔄 Rescheduling all reminders from database...');
      
      final reminders = await SupabaseService.instance.getReminders();
      
      debugPrint('📋 Found ${reminders.length} reminders in database');
      
      for (var reminder in reminders) {
        try {
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
          
          debugPrint('✅ Rescheduled: $title at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
        } catch (e) {
          debugPrint('❌ Error rescheduling reminder ${reminder['id']}: $e');
        }
      }
      
      debugPrint('✅ Finished rescheduling reminders');
    } catch (e) {
      debugPrint('❌ Error rescheduling reminders: $e');
    }
  }
}
