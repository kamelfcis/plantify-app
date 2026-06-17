import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/glass_card.dart';
import '../../../../../../core/widgets/gradient_button.dart';
import '../../../../../../services/notification_service.dart';
import '../../../../../../services/supabase_service.dart';

class RemindersCard extends StatefulWidget {
  const RemindersCard({super.key});

  @override
  State<RemindersCard> createState() => _RemindersCardState();
}

class _RemindersCardState extends State<RemindersCard> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _showForm = false;

  Future<void> _createReminder() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      try {
        final formData = _formKey.currentState!.value;
        final title = formData['title'] as String;
        final time = formData['time'] as TimeOfDay;
        final repeat = formData['repeat'] as String;
        final tips = formData['tips'] as String? ?? '';

        // Schedule notification and get notification ID
        final notificationId = await NotificationService.instance.scheduleReminder(
          title: title,
          time: time,
          repeat: repeat,
          tips: tips,
        );

        // Save to database
        final reminder = await SupabaseService.instance.createReminder(
          title: title,
          time: time,
          repeat: repeat,
          tips: tips.isNotEmpty ? tips : null,
        );

        // Update reminder with notification ID
        await SupabaseService.instance.updateReminderNotificationId(
          reminder['id'] as String,
          notificationId,
        );

        if (mounted) {
          // Show success with scheduled time info
          final scheduledTime = time.format(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder created! Will notify at $scheduledTime'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Debug: Check pending notifications
          final pending = await NotificationService.instance.getPendingNotifications();
          debugPrint('📋 Total pending notifications: ${pending.length}');
          for (var notif in pending) {
            debugPrint('   - ID: ${notif.id}, Title: ${notif.title}, Body: ${notif.body}');
          }
          
          setState(() => _showForm = false);
          _formKey.currentState?.reset();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating reminder: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// Open battery optimization settings so the user can whitelist the app.
  /// Samsung and other OEMs kill background processes aggressively.
  void _openBatterySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.battery_alert, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text('Fix Reminder Notifications')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Samsung and some Android phones may block reminder alarms due to battery optimization.\n',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'To fix this, follow these steps:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text('1. Tap "Open Settings" below'),
            Text('2. Find "Plant Care" in the app list'),
            Text('3. Set battery to "Unrestricted"'),
            Text('4. Also check:'),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Settings → Apps → Plant Care → Battery → Unrestricted'),
                  Text('• Settings → Battery → Background usage limits → Remove Plant Care'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _launchBatteryIntent();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Launch battery optimization settings using platform channel
  Future<void> _launchBatteryIntent() async {
    try {
      // Try to open battery optimization settings directly
      const platform = MethodChannel('com.example.plant_care_marketplace/battery');
      await platform.invokeMethod('openBatteryOptimization');
    } catch (e) {
      debugPrint('Could not open battery settings: $e');
      // If platform channel fails, that's okay - the dialog gives manual instructions
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return GlassCard(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _showForm = false),
                  ),
                  Expanded(
                    child: Text(
                      'Create Reminder',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'title',
                decoration: const InputDecoration(
                  labelText: 'Reminder Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderField<TimeOfDay>(
                name: 'time',
                builder: (field) => InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      field.didChange(time);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Time',
                      prefixIcon: const Icon(Icons.access_time),
                      suffixIcon: field.value != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => field.didChange(null),
                            )
                          : null,
                    ),
                    child: Text(
                      field.value?.format(context) ?? 'Select time',
                    ),
                  ),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'repeat',
                decoration: const InputDecoration(
                  labelText: 'Repeat',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'Once', child: Text('Once')),
                ],
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'tips',
                decoration: const InputDecoration(
                  labelText: 'Care Tips (Optional)',
                  hintText: 'e.g., Water thoroughly, check soil moisture',
                  prefixIcon: Icon(Icons.lightbulb_outline),
                  helperText: 'These tips will appear in the notification',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Create Reminder',
                onPressed: _createReminder,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              // Test notification button
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        try {
                          await NotificationService.instance.testNotification();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Test notification sent! Check your notification bar.'),
                                backgroundColor: AppColors.info,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Test failed: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.notifications_active, size: 18),
                      label: const Text('Test', overflow: TextOverflow.ellipsis),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _openBatterySettings(context),
                      icon: const Icon(Icons.battery_saver, size: 18),
                      label: const Text('Battery Fix', overflow: TextOverflow.ellipsis),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => context.push('/reminders'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.notifications_active, color: AppColors.warning, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Care Reminders',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View all your reminders',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          TextButton.icon(
            onPressed: () => setState(() => _showForm = true),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create New Reminder'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

