class AppConstants {
  // App Info
  static const String appName = 'Plant Care';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String userIdKey = 'user_id';

  // Supabase
  static const String supabaseUrl = 'https://jsmueppwjwngobmtzhct.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpzbXVlcHB3anduZ29ibXR6aGN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwOTQ2MTIsImV4cCI6MjA4MjY3MDYxMn0._0QvmvwIwtsRBJ7QNEQZCrSIRT2wVvSVqzf8nmJiZV0';

  // Storage Buckets
  static const String plantImagesBucket = 'plant-images';
  static const String productImagesBucket = 'product-images';
  static const String userUploadsBucket = 'user-uploads';

  // Notification Channels
  static const String reminderChannelId = 'plant_reminders';
  static const String reminderChannelName = 'Plant Care Reminders';
  static const String reminderChannelDescription = 'Notifications for plant care reminders';
}

