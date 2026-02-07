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
    // Set last_seen to a past time so admin sees user as offline immediately
    try {
      final user = currentUser;
      if (user != null) {
        await _client.from('profiles').update({
          'last_seen': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        }).eq('id', user.id);
      }
    } catch (_) {}
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

  // ====================================================
  // MARKETPLACE METHODS (USER)
  // ====================================================

  // Get all products (public read)
  Future<List<Map<String, dynamic>>> getProducts({String? category}) async {
    var query = _client.from('products').select();
    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }
    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Get product by ID
  Future<Map<String, dynamic>> getProductById(String productId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('id', productId)
        .single();
    return response;
  }

  // Get product categories
  Future<List<String>> getProductCategories() async {
    final response = await _client
        .from('products')
        .select('category')
        .order('category');
    final categories = (response as List)
        .map((e) => e['category'] as String)
        .toSet()
        .toList();
    return categories;
  }

  // Create order (user)
  Future<Map<String, dynamic>> createOrder({
    required double totalAmount,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    bool isGift = false,
    Map<String, dynamic>? giftInfo,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Generate order number
    final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    // Insert order
    final order = await _client.from('orders').insert({
      'user_id': user.id,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'status': 'pending',
      'is_gift': isGift,
    }).select().single();

    final orderId = order['id'];

    // Insert order items
    for (final item in items) {
      await _client.from('order_items').insert({
        'order_id': orderId,
        'product_id': item['product_id'],
        'product_name': item['product_name'],
        'product_price': item['product_price'],
        'quantity': item['quantity'],
        'subtotal': item['subtotal'],
      });
    }

    // Insert gift info if applicable
    if (isGift && giftInfo != null) {
      await _client.from('gifts').insert({
        'order_id': orderId,
        'sender_id': user.id,
        'receiver_name': giftInfo['receiver_name'],
        'receiver_email': giftInfo['receiver_email'],
        'receiver_address': shippingAddress,
        'gift_message': giftInfo['gift_message'],
      });
    }

    return order;
  }

  // Get user orders
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // ====================================================
  // ADMIN METHODS
  // ====================================================

  // Get all users/profiles
  Future<List<Map<String, dynamic>>> getAllProfiles() async {
    final response = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Update last_seen for current user
  Future<void> updateLastSeen() async {
    final user = currentUser;
    if (user == null) return;
    await _client.from('profiles').update({
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }

  // Block/Unblock a user
  Future<void> toggleUserBlock(String userId, bool isBlocked) async {
    await _client.from('profiles').update({
      'is_blocked': isBlocked,
    }).eq('id', userId);
  }

  // Get all products (admin)
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Create product (admin)
  Future<Map<String, dynamic>> createProduct({
    required String name,
    String? description,
    required double price,
    required String category,
    String? imageUrl,
    bool inStock = true,
    int stockQuantity = 0,
  }) async {
    final response = await _client.from('products').insert({
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
    }).select().single();
    return response;
  }

  // Update product (admin)
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _client.from('products').update(data).eq('id', productId);
  }

  // Delete product (admin)
  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('id', productId);
  }

  // Upload product image (admin)
  Future<String> uploadProductImage(String filePath, String fileName) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileExtension = fileName.split('.').last;
    final uniqueFileName = 'products/${timestamp}_$fileName';

    final file = File(filePath);
    await _client.storage.from('product-images').upload(
      uniqueFileName,
      file,
      fileOptions: FileOptions(
        contentType: 'image/$fileExtension',
        upsert: false,
      ),
    );

    final imageUrl = _client.storage.from('product-images').getPublicUrl(uniqueFileName);
    return imageUrl;
  }

  // Get all orders (admin)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*, products:product_id(image_url)), gifts(*)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Update order status (admin)
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.from('orders').update({
      'status': status,
    }).eq('id', orderId);
  }

  // Get order details with items (admin)
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*, products:product_id(image_url)), gifts(*)')
        .eq('id', orderId)
        .single();
    return response;
  }

  // Get user profile by ID
  Future<Map<String, dynamic>?> getProfileById(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Get dashboard stats
  Future<Map<String, int>> getAdminStats() async {
    final profiles = await _client.from('profiles').select('id');
    final products = await _client.from('products').select('id');
    final orders = await _client.from('orders').select('id');
    final gifts = await _client.from('gifts').select('id');

    return {
      'users': (profiles as List).length,
      'products': (products as List).length,
      'orders': (orders as List).length,
      'gifts': (gifts as List).length,
    };
  }
}

