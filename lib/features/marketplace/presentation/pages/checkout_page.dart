import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../services/supabase_service.dart';
import '../../../../services/shipping_prefs_service.dart';
import '../managers/cart_manager.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final _supabase = SupabaseService.instance;
  final _cartManager = CartManager.instance;
  final _shippingPrefs = ShippingPrefsService.instance;
  bool _isGift = false;
  bool _isProcessing = false;
  bool _isFetchingLocation = false;

  // Phone field state
  String _completePhoneNumber = '';
  String _phoneCountryCode = 'EG'; // Default to Egypt
  String? _phoneValidationError;

  // Controllers for pre-filling saved data
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();

  late AnimationController _successController;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successScale = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    _loadSavedShippingInfo();
  }

  @override
  void dispose() {
    _successController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  /// Load saved shipping info from SharedPreferences
  Future<void> _loadSavedShippingInfo() async {
    final saved = await _shippingPrefs.loadShippingInfo();
    if (saved != null && mounted) {
      setState(() {
        _fullNameController.text = saved['fullName'] ?? '';
        _emailController.text = saved['email'] ?? '';
        _phoneController.text = saved['phoneNumber'] ?? saved['phone'] ?? '';
        _completePhoneNumber = saved['phone'] ?? '';
        _phoneCountryCode = saved['phoneCountryCode'] ?? 'EG';
        _addressController.text = saved['address'] ?? '';
        _cityController.text = saved['city'] ?? '';
        _zipCodeController.text = saved['zipCode'] ?? '';
        _countryController.text = saved['country'] ?? '';
      });
    }
  }

  /// Save current shipping info to SharedPreferences
  Future<void> _saveShippingInfo(Map<String, dynamic> data) async {
    final shippingInfo = {
      'fullName': data['fullName'] ?? '',
      'email': data['email'] ?? '',
      'phone': _completePhoneNumber,
      'phoneNumber': _phoneController.text,
      'phoneCountryCode': _phoneCountryCode,
      'address': data['address'] ?? '',
      'city': data['city'] ?? '',
      'zipCode': data['zipCode'] ?? '',
      'country': data['country'] ?? '',
    };
    await _shippingPrefs.saveShippingInfo(shippingInfo);
  }

  /// Get current location and fill address, city, country from maps
  Future<void> _fetchLocationFromMaps() async {
    setState(() => _isFetchingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        setState(() => _isFetchingLocation = false);
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          setState(() => _isFetchingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permissions are permanently denied. Please enable them in settings.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() => _isFetchingLocation = false);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Reverse geocode to get address
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() {
          // Build a full address string
          final addressParts = <String>[];
          if (place.street != null && place.street!.isNotEmpty) {
            addressParts.add(place.street!);
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            addressParts.add(place.subLocality!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          _addressController.text = addressParts.join(', ');

          _cityController.text = place.administrativeArea ?? place.locality ?? '';
          _countryController.text = place.country ?? '';

          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            _zipCodeController.text = place.postalCode!;
          }
        });

        // Update form fields
        _formKey.currentState?.fields['address']?.didChange(_addressController.text);
        _formKey.currentState?.fields['city']?.didChange(_cityController.text);
        _formKey.currentState?.fields['country']?.didChange(_countryController.text);
        if (_zipCodeController.text.isNotEmpty) {
          _formKey.currentState?.fields['zipCode']?.didChange(_zipCodeController.text);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Location fetched successfully!')),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _processOrder() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    // Validate phone number
    if (_completePhoneNumber.isEmpty || _phoneController.text.isEmpty) {
      setState(() => _phoneValidationError = 'Phone number is required');
      return;
    }

    if (_cartManager.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final data = _formKey.currentState!.value;

      final shippingAddress = {
        'fullName': data['fullName'],
        'email': data['email'],
        'phone': _completePhoneNumber,
        'address': data['address'],
        'city': data['city'],
        'zipCode': data['zipCode'] ?? '',
        'country': data['country'],
      };

      // Save shipping info for future use
      await _saveShippingInfo(data);

      final items = _cartManager.items
          .map((item) => {
                'product_id': item.product.id,
                'product_name': item.product.name,
                'product_price': item.product.price,
                'quantity': item.quantity,
                'subtotal': item.total,
              })
          .toList();

      Map<String, dynamic>? giftInfo;
      if (_isGift) {
        giftInfo = {
          'receiver_name': data['receiverName'],
          'receiver_email': data['receiverEmail'],
          'gift_message': data['giftMessage'] ?? '',
        };
      }

      await _supabase.createOrder(
        totalAmount: _cartManager.total,
        shippingAddress: shippingAddress,
        items: items,
        isGift: _isGift,
        giftInfo: giftInfo,
      );

      // Clear cart after successful order
      _cartManager.clear();

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    _successController.forward(from: 0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ScaleTransition(
        scale: _successScale,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: AppColors.success, size: 60),
              ),
              const SizedBox(height: 20),
              Text(
                'Order Placed! 🎉',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _isGift
                    ? 'Your gift order has been placed successfully!\nThe recipient will love it!'
                    : 'Your order has been placed successfully!\nYou will receive a confirmation soon.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Back to Home',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                width: double.infinity,
                icon: Icons.home,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/marketplace');
                },
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cartManager.isEmpty && !_isProcessing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined,
                  size: 80, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text('Your cart is empty',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Browse Marketplace',
                onPressed: () => context.go('/marketplace'),
                width: 220,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Items Summary
              GlassCard(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Order Items (${_cartManager.itemCount})',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._cartManager.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: item.product.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.product.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.local_florist,
                                                  size: 20),
                                        ),
                                      )
                                    : const Icon(Icons.local_florist, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${item.product.name} × ${item.quantity}',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '${item.total.toStringAsFixed(2)} LE',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              // Gift Option
              GlassCard(
                margin: const EdgeInsets.only(bottom: 20),
                child: InkWell(
                  onTap: () => setState(() => _isGift = !_isGift),
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _isGift
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _isGift
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: _isGift
                              ? AppColors.white
                              : Colors.transparent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Send as Gift 🎁',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Add a personal message',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.card_giftcard, color: AppColors.primary),
                    ],
                  ),
                ),
              ),

              // Shipping Information Header with Location Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Shipping Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  // Get Location Button
                  ElevatedButton.icon(
                    onPressed: _isFetchingLocation ? null : _fetchLocationFromMaps,
                    icon: _isFetchingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.my_location, size: 16),
                    label: Text(
                      _isFetchingLocation ? 'Getting...' : 'Use My Location',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'fullName',
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'email',
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              const SizedBox(height: 12),
              IntlPhoneField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorText: _phoneValidationError,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                initialCountryCode: _phoneCountryCode,
                disableLengthCheck: true,
                dropdownTextStyle: Theme.of(context).textTheme.bodyMedium,
                style: Theme.of(context).textTheme.bodyMedium,
                flagsButtonPadding: const EdgeInsets.only(left: 12),
                showDropdownIcon: true,
                dropdownIconPosition: IconPosition.trailing,
                dropdownIcon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                onChanged: (PhoneNumber phone) {
                  setState(() {
                    _completePhoneNumber = phone.completeNumber;
                    _phoneValidationError = null;
                  });
                },
                onCountryChanged: (country) {
                  setState(() {
                    _phoneCountryCode = country.code;
                  });
                },
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'address',
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.home_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.location_on, color: AppColors.primary),
                    tooltip: 'Get from maps',
                    onPressed: _isFetchingLocation ? null : _fetchLocationFromMaps,
                  ),
                ),
                maxLines: 2,
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'city',
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'zipCode',
                      controller: _zipCodeController,
                      decoration: const InputDecoration(
                        labelText: 'ZIP Code (Optional)',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      // No required validator - zipCode is optional
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'country',
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        prefixIcon: Icon(Icons.public),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                ],
              ),

              // Gift Information
              if (_isGift) ...[
                const SizedBox(height: 20),
                Text(
                  'Gift Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                FormBuilderTextField(
                  name: 'receiverName',
                  decoration: const InputDecoration(
                    labelText: 'Receiver Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 12),
                FormBuilderTextField(
                  name: 'receiverEmail',
                  decoration: const InputDecoration(
                    labelText: 'Receiver Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 12),
                FormBuilderTextField(
                  name: 'giftMessage',
                  decoration: const InputDecoration(
                    labelText: 'Gift Message',
                    prefixIcon: Icon(Icons.message_outlined),
                    hintText: 'Write a personal message...',
                  ),
                  maxLines: 3,
                ),
              ],

              const SizedBox(height: 24),

              // Order Summary
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                        'Subtotal', _cartManager.subtotal),
                    _buildSummaryRow(
                        'Shipping', _cartManager.shipping),
                    _buildSummaryRow(
                        'Tax (8%)', _cartManager.tax),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_cartManager.total.toStringAsFixed(2)} LE',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Place Order Button
              GradientButton(
                text: _isProcessing ? 'Processing...' : 'Place Order',
                onPressed: _isProcessing ? null : _processOrder,
                width: double.infinity,
                icon: _isProcessing ? null : Icons.check_circle,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} LE',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
