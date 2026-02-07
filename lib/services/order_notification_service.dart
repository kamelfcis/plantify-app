import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Listens to Supabase Realtime for order events and shows local notifications.
///
/// - **Admin side**: listens for NEW orders (INSERT on `orders` table)
/// - **User side**: listens for ORDER STATUS changes (UPDATE on `orders` table)
class OrderNotificationService {
  static final OrderNotificationService _instance =
      OrderNotificationService._internal();
  factory OrderNotificationService() => _instance;
  static OrderNotificationService get instance => _instance;

  OrderNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  RealtimeChannel? _adminChannel;
  RealtimeChannel? _userChannel;

  bool _initialized = false;

  // Callback for UI updates (e.g., refresh orders list, show badge)
  VoidCallback? onNewOrderForAdmin;
  void Function(String orderId, String newStatus)? onStatusChangeForUser;

  /// Initialize notification plugin (separate from the reminder channel)
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@android:drawable/sym_def_app_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    // Create a dedicated channel for order notifications
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      const channel = AndroidNotificationChannel(
        'order_notifications',
        'Order Notifications',
        description: 'Notifications for new orders and status updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await androidImpl.createNotificationChannel(channel);
    }

    _initialized = true;
    debugPrint('✅ OrderNotificationService initialized');
  }

  // ============================================================
  // ADMIN: Listen for new orders
  // ============================================================

  /// Start listening for new orders (call from admin dashboard)
  void startAdminListener() {
    stopAdminListener(); // Clean up any existing subscription

    final client = SupabaseService.instance.client;

    _adminChannel = client.channel('admin-new-orders');
    _adminChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            debugPrint('🔔 [Admin] New order received: ${payload.newRecord}');
            _showAdminNewOrderNotification(payload.newRecord);
            onNewOrderForAdmin?.call();
          },
        )
        .subscribe();

    debugPrint('📡 Admin realtime listener started (orders INSERT)');
  }

  /// Stop admin listener
  void stopAdminListener() {
    if (_adminChannel != null) {
      SupabaseService.instance.client.removeChannel(_adminChannel!);
      _adminChannel = null;
      debugPrint('🔇 Admin realtime listener stopped');
    }
  }

  /// Show a local notification to the admin about a new order
  Future<void> _showAdminNewOrderNotification(
      Map<String, dynamic> order) async {
    if (!_initialized) await initialize();

    final orderNumber = order['order_number'] ?? 'New';
    final totalAmount = order['total_amount'];
    final isGift = order['is_gift'] == true;

    final title = isGift ? '🎁 New Gift Order!' : '🛒 New Order Received!';
    final body = isGift
        ? 'Gift Order #$orderNumber — \$${_formatAmount(totalAmount)}'
        : 'Order #$orderNumber — \$${_formatAmount(totalAmount)}';

    const androidDetails = AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for new orders and status updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@android:drawable/sym_def_app_icon',
      color: Color(0xFF4CAF50),
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

    final notifId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _notifications.show(notifId, title, body, details);
    debugPrint('✅ Admin notification shown: $title');
  }

  // ============================================================
  // USER: Listen for order status changes
  // ============================================================

  /// Start listening for status changes on the current user's orders
  void startUserListener() {
    stopUserListener(); // Clean up any existing subscription

    final client = SupabaseService.instance.client;
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) {
      debugPrint('⚠️ No authenticated user — skipping user order listener');
      return;
    }

    _userChannel = client.channel('user-order-status');
    _userChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            debugPrint(
                '🔔 [User] Order status changed: ${payload.newRecord}');
            final oldStatus = payload.oldRecord['status'] as String?;
            final newStatus = payload.newRecord['status'] as String?;
            final orderId = payload.newRecord['id'] as String?;

            if (newStatus != null && newStatus != oldStatus) {
              _showUserStatusNotification(payload.newRecord, newStatus);
              if (orderId != null) {
                onStatusChangeForUser?.call(orderId, newStatus);
              }
            }
          },
        )
        .subscribe();

    debugPrint(
        '📡 User realtime listener started (orders UPDATE for $userId)');
  }

  /// Stop user listener
  void stopUserListener() {
    if (_userChannel != null) {
      SupabaseService.instance.client.removeChannel(_userChannel!);
      _userChannel = null;
      debugPrint('🔇 User realtime listener stopped');
    }
  }

  /// Show a local notification to the user about their order status change
  Future<void> _showUserStatusNotification(
      Map<String, dynamic> order, String newStatus) async {
    if (!_initialized) await initialize();

    final orderNumber = order['order_number'] ?? '';

    String title;
    String body;
    switch (newStatus.toLowerCase()) {
      case 'processing':
        title = '📦 Order Being Processed';
        body =
            'Your order #$orderNumber is now being prepared!';
        break;
      case 'shipped':
        title = '🚚 Order Shipped!';
        body =
            'Your order #$orderNumber is on its way to you!';
        break;
      case 'delivered':
        title = '✅ Order Delivered!';
        body =
            'Your order #$orderNumber has been delivered. Enjoy your plants! 🌿';
        break;
      case 'cancelled':
        title = '❌ Order Cancelled';
        body =
            'Your order #$orderNumber has been cancelled.';
        break;
      default:
        title = '📋 Order Update';
        body =
            'Your order #$orderNumber status changed to $newStatus.';
    }

    const androidDetails = AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for new orders and status updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@android:drawable/sym_def_app_icon',
      color: Color(0xFF4CAF50),
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

    final notifId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _notifications.show(notifId, title, body, details);
    debugPrint('✅ User notification shown: $title');
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    if (amount is num) return amount.toStringAsFixed(2);
    return amount.toString();
  }

  /// Clean up all listeners
  void dispose() {
    stopAdminListener();
    stopUserListener();
  }
}

