import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  static PermissionService get instance => _instance;

  PermissionService._internal();

  static const String _permissionsRequestedKey = 'permissions_requested';

  /// Check if permissions have been requested before
  Future<bool> hasRequestedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionsRequestedKey) ?? false;
  }

  /// Mark that permissions have been requested
  Future<void> markPermissionsRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsRequestedKey, true);
  }

  /// Request notification permission (Android 13+)
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      debugPrint('📱 Notification permission status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Error checking notification permission: $e');
      return false;
    }
  }

  /// Request alarm permission (Android 12+)
  Future<bool> requestAlarmPermission() async {
    try {
      // For Android 12+, we need to check if exact alarms are allowed
      // Note: USE_EXACT_ALARM is automatically granted for system apps
      // For regular apps, we can use SCHEDULE_EXACT_ALARM
      final status = await Permission.scheduleExactAlarm.request();
      debugPrint('⏰ Alarm permission status: $status');
      return status.isGranted || status.isPermanentlyDenied;
    } catch (e) {
      debugPrint('❌ Error requesting alarm permission: $e');
      return false;
    }
  }

  /// Check if alarm permission is granted
  Future<bool> isAlarmPermissionGranted() async {
    try {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Error checking alarm permission: $e');
      return false;
    }
  }

  /// Request all permissions (notifications + alarms)
  Future<Map<String, bool>> requestAllPermissions() async {
    debugPrint('🔐 Requesting all permissions...');
    
    final results = <String, bool>{};
    
    // Request notification permission
    results['notification'] = await requestNotificationPermission();
    
    // Request alarm permission
    results['alarm'] = await requestAlarmPermission();
    
      // Also request through notification service (for Android 13+)
      try {
        // Initialize notification service first
        await NotificationService.instance.initialize();
        
        // Access the notifications plugin through a public method
        final androidImplementation = await NotificationService.instance.getAndroidImplementation();
        
        if (androidImplementation != null) {
          final granted = await androidImplementation.requestNotificationsPermission();
          debugPrint('📱 Notification permission (via service): $granted');
          // Handle nullable bool - if granted is true, update result
          if (granted == true) {
            results['notification'] = true;
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error requesting notification via service: $e');
      }
    
    // Mark as requested
    await markPermissionsRequested();
    
    debugPrint('✅ Permission request results: $results');
    return results;
  }

  /// Show permission dialog and request permissions
  Future<bool> showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionDialog(),
    ) ?? false;
  }
}

/// Permission request dialog
class PermissionDialog extends StatefulWidget {
  const PermissionDialog({super.key});

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  bool _isRequesting = false;
  bool _notificationGranted = false;
  bool _alarmGranted = false;

  Future<void> _requestPermissions() async {
    setState(() => _isRequesting = true);

    try {
      final results = await PermissionService.instance.requestAllPermissions();
      
      setState(() {
        _notificationGranted = results['notification'] ?? false;
        _alarmGranted = results['alarm'] ?? false;
        _isRequesting = false;
      });

      // Wait a moment to show results
      await Future.delayed(const Duration(milliseconds: 500));

      // Close dialog
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('❌ Error in permission dialog: $e');
      setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.orange),
          SizedBox(width: 12),
          Text('Enable Notifications & Alarms'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To send you timely reminders for plant care, we need your permission to:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            icon: Icons.notifications,
            title: 'Notifications',
            description: 'Receive reminders for watering, fertilizing, and plant care',
            granted: _notificationGranted,
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            icon: Icons.alarm,
            title: 'Alarms',
            description: 'Schedule exact reminders at specific times',
            granted: _alarmGranted,
          ),
          if (_isRequesting) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isRequesting) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: _requestPermissions,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Allow'),
          ),
        ],
      ],
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: granted ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: granted ? Colors.green : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        if (granted)
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
      ],
    );
  }
}

