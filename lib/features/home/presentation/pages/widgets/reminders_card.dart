import 'package:flutter/material.dart';
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
              TextButton.icon(
                onPressed: () async {
                  try {
                    await NotificationService.instance.testNotification();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification scheduled for 5 seconds!'),
                          backgroundColor: AppColors.info,
                          duration: Duration(seconds: 2),
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
                label: const Text('Test Notification (5 sec)'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
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

