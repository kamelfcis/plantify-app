import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../services/supabase_service.dart';
import '../managers/cart_manager.dart';
import '../models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  final _supabase = SupabaseService.instance;
  final _cartManager = CartManager.instance;

  Product? _product;
  bool _isLoading = true;
  int _quantity = 1;

  // Animations
  late AnimationController _cartBtnController;
  late Animation<double> _cartBtnScale;
  late AnimationController _flyController;
  late Animation<double> _flyAnimation;
  bool _showCartSuccess = false;

  @override
  void initState() {
    super.initState();

    _cartBtnController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _cartBtnScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _cartBtnController,
      curve: Curves.easeInOut,
    ));

    _flyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _flyAnimation = CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeInOut,
    );

    _loadProduct();
  }

  @override
  void dispose() {
    _cartBtnController.dispose();
    _flyController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final data = await _supabase.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = Product.fromMap(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading product: $e')),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) return;

    // Play animation
    setState(() => _showCartSuccess = true);
    await _cartBtnController.forward(from: 0);
    await _flyController.forward(from: 0);

    _cartManager.addToCart(_product!, quantity: _quantity);

    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$_quantity × ${_product!.name} added to cart!',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: AppColors.white,
            onPressed: () => context.push('/marketplace/cart'),
          ),
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _showCartSuccess = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Product not found')),
      );
    }

    final product = _product!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image
          SliverAppBar(
            expandedHeight: screenWidth * 0.75, // Responsive height
            pinned: true,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/marketplace/cart'),
                  ),
                  if (_cartManager.itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_cartManager.itemCount}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(Icons.local_florist,
                              size: 120, color: AppColors.white),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Center(
                        child: Icon(Icons.local_florist,
                            size: 120, color: AppColors.white),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Category
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.inStock
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: product.inStock
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.inStock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: product.inStock
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'No description available.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuantityButton(
                          Icons.remove,
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: Text(
                            '$_quantity',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildQuantityButton(
                          Icons.add,
                          onPressed: () => setState(() => _quantity++),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Total: \$${(product.price * _quantity).toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Add to Cart Button (animated)
                  ScaleTransition(
                    scale: _cartBtnScale,
                    child: GradientButton(
                      text: _showCartSuccess ? 'Added! ✓' : 'Add to Cart',
                      onPressed: product.inStock ? _addToCart : null,
                      width: double.infinity,
                      icon: _showCartSuccess
                          ? Icons.check_circle
                          : Icons.shopping_cart,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Buy as Gift
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: product.inStock
                          ? () {
                              _cartManager.addToCart(product,
                                  quantity: _quantity);
                              context.push('/marketplace/checkout');
                            }
                          : null,
                      icon: const Icon(Icons.card_giftcard),
                      label: const Text('Buy as Gift'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, {VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: onPressed != null
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}
