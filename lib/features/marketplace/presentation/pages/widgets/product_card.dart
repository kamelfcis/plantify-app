import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../models/product_model.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _cartAnimController;
  late Animation<double> _cartScaleAnimation;
  bool _showCartCheck = false;

  @override
  void initState() {
    super.initState();
    _cartAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cartScaleAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _cartAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cartAnimController.dispose();
    super.dispose();
  }

  void _handleAddToCart() async {
    setState(() => _showCartCheck = true);
    await _cartAnimController.forward();
    await _cartAnimController.reverse();
    widget.onAddToCart?.call();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _showCartCheck = false);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.product.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.local_florist,
                                size: 50,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.local_florist,
                              size: 50,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                  ),
                ),
                // Quick add to cart button
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: ScaleTransition(
                    scale: _cartScaleAnimation
                        .drive(Tween(begin: 1.0, end: 1.0)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _showCartCheck
                            ? AppColors.success
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleAddToCart,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                _showCartCheck
                                    ? Icons.check
                                    : Icons.add_shopping_cart,
                                color: AppColors.white,
                                size: 18,
                                key: ValueKey(_showCartCheck),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Out of stock overlay
                if (!widget.product.inStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Product Name
          Text(
            widget.product.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Price + Category
          Row(
            children: [
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.product.category,
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
