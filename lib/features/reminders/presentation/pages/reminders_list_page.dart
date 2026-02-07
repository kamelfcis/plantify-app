import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../services/supabase_service.dart';
import '../../../../services/notification_service.dart';

class RemindersListPage extends StatefulWidget {
  const RemindersListPage({super.key});

  @override
  State<RemindersListPage> createState() => _RemindersListPageState();
}

class _RemindersListPageState extends State<RemindersListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allReminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final reminders = await SupabaseService.instance.getReminders();
      setState(() {
        _allReminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reminders: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _upcomingReminders {
    final now = DateTime.now();
    return _allReminders.where((reminder) {
      if (reminder['is_active'] != true) return false;
      final timeStr = reminder['scheduled_time'] as String;
      final timeParts = timeStr.split(':');
      final reminderTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      final reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );
      return reminderDateTime.isAfter(now) || reminderDateTime.isAtSameMomentAs(now);
    }).toList()
      ..sort((a, b) {
        final timeA = _getNextOccurrence(a);
        final timeB = _getNextOccurrence(b);
        return timeA.compareTo(timeB);
      });
  }

  List<Map<String, dynamic>> get _pastReminders {
    final now = DateTime.now();
    return _allReminders.where((reminder) {
      if (reminder['is_active'] != true) return false;
      final timeStr = reminder['scheduled_time'] as String;
      final timeParts = timeStr.split(':');
      final reminderTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      final reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );
      return reminderDateTime.isBefore(now);
    }).toList()
      ..sort((a, b) {
        final timeA = _getLastOccurrence(a);
        final timeB = _getLastOccurrence(b);
        return timeB.compareTo(timeA); // Most recent first
      });
  }

  List<Map<String, dynamic>> get _activeReminders {
    return _allReminders.where((r) => r['is_active'] == true).toList()
      ..sort((a, b) {
        final timeA = _getNextOccurrence(a);
        final timeB = _getNextOccurrence(b);
        return timeA.compareTo(timeB);
      });
  }

  List<Map<String, dynamic>> get _inactiveReminders {
    return _allReminders.where((r) => r['is_active'] != true).toList()
      ..sort((a, b) {
        final createdAtA = DateTime.parse(a['created_at'] as String);
        final createdAtB = DateTime.parse(b['created_at'] as String);
        return createdAtB.compareTo(createdAtA); // Most recent first
      });
  }

  DateTime _getNextOccurrence(Map<String, dynamic> reminder) {
    final now = DateTime.now();
    final timeStr = reminder['scheduled_time'] as String;
    final timeParts = timeStr.split(':');
    final reminderTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    
    var nextOccurrence = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    
    if (nextOccurrence.isBefore(now)) {
      nextOccurrence = nextOccurrence.add(const Duration(days: 1));
    }
    
    return nextOccurrence;
  }

  DateTime _getLastOccurrence(Map<String, dynamic> reminder) {
    final now = DateTime.now();
    final timeStr = reminder['scheduled_time'] as String;
    final timeParts = timeStr.split(':');
    final reminderTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    
    var lastOccurrence = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    
    if (lastOccurrence.isAfter(now)) {
      lastOccurrence = lastOccurrence.subtract(const Duration(days: 1));
    }
    
    return lastOccurrence;
  }

  Future<void> _toggleReminderStatus(Map<String, dynamic> reminder) async {
    try {
      final currentStatus = reminder['is_active'] as bool;
      final newStatus = !currentStatus;
      
      await SupabaseService.instance.toggleReminderStatus(
        reminder['id'] as String,
        newStatus,
      );
      
      // If activating, reschedule notification
      if (newStatus) {
        final timeStr = reminder['scheduled_time'] as String;
        final timeParts = timeStr.split(':');
        final time = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
        
        final notificationId = await NotificationService.instance.scheduleReminder(
          title: reminder['title'] as String,
          time: time,
          repeat: reminder['repeat_frequency'] as String? ?? 'Daily',
          tips: reminder['tips'] as String?,
        );
        
        await SupabaseService.instance.updateReminderNotificationId(
          reminder['id'] as String,
          notificationId,
        );
      } else {
        // If deactivating, cancel notification
        final notificationId = reminder['notification_id'] as int?;
        if (notificationId != null) {
          await NotificationService.instance.cancelNotification(notificationId);
        }
      }
      
      await _loadReminders();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Reminder activated' : 'Reminder deactivated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating reminder: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteReminder(Map<String, dynamic> reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Cancel notification if exists
        final notificationId = reminder['notification_id'] as int?;
        if (notificationId != null) {
          await NotificationService.instance.cancelNotification(notificationId);
        }
        
        await SupabaseService.instance.deleteReminder(reminder['id'] as String);
        await _loadReminders();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error deleting reminder: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting reminder: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
            Tab(text: 'Past', icon: Icon(Icons.history)),
            Tab(text: 'Active', icon: Icon(Icons.check_circle)),
            Tab(text: 'Inactive', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRemindersList(_upcomingReminders, isUpcoming: true),
                _buildRemindersList(_pastReminders, isPast: true),
                _buildRemindersList(_activeReminders),
                _buildRemindersList(_inactiveReminders),
              ],
            ),
    );
  }

  Widget _buildRemindersList(
    List<Map<String, dynamic>> reminders, {
    bool isUpcoming = false,
    bool isPast = false,
  }) {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _buildReminderCard(reminder, isUpcoming: isUpcoming, isPast: isPast);
        },
      ),
    );
  }

  Widget _buildReminderCard(
    Map<String, dynamic> reminder, {
    bool isUpcoming = false,
    bool isPast = false,
  }) {
    final timeStr = reminder['scheduled_time'] as String;
    final timeParts = timeStr.split(':');
    final time = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    final repeat = reminder['repeat_frequency'] as String? ?? 'Daily';
    final tips = reminder['tips'] as String?;
    final isActive = reminder['is_active'] as bool;
    
    final nextOccurrence = isUpcoming ? _getNextOccurrence(reminder) : null;
    final lastOccurrence = isPast ? _getLastOccurrence(reminder) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isActive ? Icons.notifications_active : Icons.notifications_off,
                            color: isActive ? AppColors.success : AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reminder['title'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            time.format(context),
                            style: TextStyle(color: AppColors.secondary),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.repeat, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            repeat,
                            style: TextStyle(color: AppColors.secondary),
                          ),
                        ],
                      ),
                      if (nextOccurrence != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Next: ${DateFormat('MMM dd, yyyy at ${time.format(context)}').format(nextOccurrence)}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (lastOccurrence != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Last: ${DateFormat('MMM dd, yyyy at ${time.format(context)}').format(lastOccurrence)}',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (tips != null && tips.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb, size: 16, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tips,
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.pause : Icons.play_arrow,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteReminder(reminder);
                    } else if (value == 'toggle') {
                      _toggleReminderStatus(reminder);
                    }
                  },
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

