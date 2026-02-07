import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase (non-blocking - catch errors)
  try {
    await SupabaseService.instance.initialize();
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
    // Continue app startup even if Supabase fails
  }

  // Initialize Notifications (non-blocking - catch errors)
  try {
    await NotificationService.instance.initialize();
    
    // Reschedule all reminders from database on app startup
    // This ensures reminders persist after app restarts
    try {
      await NotificationService.instance.rescheduleAllReminders();
    } catch (e) {
      debugPrint('Rescheduling reminders failed: $e');
      // Continue even if rescheduling fails
    }
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
    // Continue app startup even if notifications fail
  }

  runApp(
    const ProviderScope(
      child: PlantCareApp(),
    ),
  );
}

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Plant Care',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

