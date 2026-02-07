import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/supabase_service.dart';
import '../../services/notification_service.dart';

// Supabase Client Provider
final supabaseClientProvider = Provider((ref) {
  return SupabaseService.instance.client;
});

// Auth State Provider
final authStateProvider = StreamProvider((ref) {
  return SupabaseService.instance.authStateChanges;
});

// Current User Provider
final currentUserProvider = Provider((ref) {
  return SupabaseService.instance.currentUser;
});

// Is Authenticated Provider
final isAuthenticatedProvider = Provider((ref) {
  return SupabaseService.instance.isAuthenticated;
});

// Notification Service Provider
final notificationServiceProvider = Provider((ref) {
  return NotificationService.instance;
});

