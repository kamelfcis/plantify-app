import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../services/supabase_service.dart';
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
  bool _isGift = false;
  bool _isProcessing = false;

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
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _processOrder() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
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
        'phone': data['phone'],
        'address': data['address'],
        'city': data['city'],
        'zipCode': data['zipCode'],
        'country': data['country'],
      };

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
                                '\$${item.total.toStringAsFixed(2)}',
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

              // Shipping Information
              Text(
                'Shipping Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'fullName',
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'email',
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
              FormBuilderTextField(
                name: 'phone',
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'address',
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                maxLines: 2,
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'city',
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
                      decoration: const InputDecoration(
                        labelText: 'ZIP Code',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'country',
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
                          '\$${_cartManager.total.toStringAsFixed(2)}',
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
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
