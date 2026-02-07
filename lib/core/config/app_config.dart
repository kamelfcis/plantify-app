import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class AppConfig {
  // Supabase Configuration
  static String get supabaseUrl {
    // In production, use environment variables or secure storage
    if (kDebugMode) {
      return AppConstants.supabaseUrl;
    }
    // For production, consider using flutter_dotenv or similar
    return const String.fromEnvironment('SUPABASE_URL', defaultValue: AppConstants.supabaseUrl);
  }

  static String get supabaseAnonKey {
    if (kDebugMode) {
      return AppConstants.supabaseAnonKey;
    }
    return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: AppConstants.supabaseAnonKey);
  }

  // App Configuration
  static const String appName = AppConstants.appName;
  static const String appVersion = AppConstants.appVersion;

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePushNotifications = true;

  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}

