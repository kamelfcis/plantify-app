import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  static SupabaseService get instance => _instance;

  SupabaseService._internal();

  late SupabaseClient _client;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );

    _client = Supabase.instance.client;
    _initialized = true;
  }

  SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client;
  }

  bool get isAuthenticated => _initialized && _client.auth.currentUser != null;

  User? get currentUser => _initialized ? _client.auth.currentUser : null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      // Create profile
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'email': email,
      });
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Reminders
  Future<Map<String, dynamic>> createReminder({
    required String title,
    required TimeOfDay time,
    required String repeat,
    String? tips,
    String? plantId,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client.from('reminders').insert({
      'user_id': user.id,
      'title': title,
      'scheduled_time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      'repeat_frequency': repeat,
      'tips': tips,
      'user_plant_id': plantId,
      'is_active': true,
    }).select().single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getReminders({bool? isActive}) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    var query = _client
        .from('reminders')
        .select()
        .eq('user_id', user.id);

    // Filter by active status if provided
    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }

    final response = await query.order('scheduled_time');

    return List<Map<String, dynamic>>.from(response);
  }
  
  Future<void> toggleReminderStatus(String reminderId, bool isActive) async {
    await _client
        .from('reminders')
        .update({'is_active': isActive})
        .eq('id', reminderId);
  }

  Future<void> updateReminderNotificationId(String reminderId, int notificationId) async {
    await _client
        .from('reminders')
        .update({'notification_id': notificationId})
        .eq('id', reminderId);
  }

  Future<void> deleteReminder(String reminderId) async {
    await _client.from('reminders').delete().eq('id', reminderId);
  }

  // Image Upload
  Future<String> uploadPlantImage(String filePath, String fileName) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Create unique file path: {user_id}/plants/{timestamp}_{filename}
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileExtension = fileName.split('.').last;
    final uniqueFileName = '${user.id}/plants/${timestamp}_$fileName';
    
    // Read file and upload to plant-images bucket
    final file = File(filePath);
    await _client.storage.from('plant-images').upload(
      uniqueFileName,
      file,
      fileOptions: FileOptions(
        contentType: 'image/$fileExtension',
        upsert: false,
      ),
    );

    // Get public URL
    final imageUrl = _client.storage.from('plant-images').getPublicUrl(uniqueFileName);
    
    return imageUrl;
  }

  // User Plants
  Future<Map<String, dynamic>> createUserPlant({
    required String name,
    String? scientificName,
    required String healthStatus,
    required int growthPercentage,
    required String dateAdded,
    String? nextWateringDate,
    String? notes,
    String? imageUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client.from('user_plants').insert({
      'user_id': user.id,
      'name': name,
      'scientific_name': scientificName,
      'health_status': healthStatus,
      'growth_percentage': growthPercentage,
      'date_added': dateAdded,
      'next_watering_date': nextWateringDate,
      'notes': notes,
      'image_url': imageUrl,
    }).select().single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getUserPlants() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client
        .from('user_plants')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteUserPlant(String plantId) async {
    await _client.from('user_plants').delete().eq('id', plantId);
  }
}

