import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import 'widgets/product_card.dart';
import '../models/product_model.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Monstera Deliciosa',
      description: 'Beautiful tropical plant with unique split leaves',
      price: 29.99,
      imageUrl: '',
      category: 'Indoor',
      inStock: true,
    ),
    Product(
      id: '2',
      name: 'Snake Plant',
      description: 'Low-maintenance plant perfect for beginners',
      price: 19.99,
      imageUrl: '',
      category: 'Indoor',
      inStock: true,
    ),
    Product(
      id: '3',
      name: 'Pothos Golden',
      description: 'Fast-growing trailing plant with golden variegation',
      price: 15.99,
      imageUrl: '',
      category: 'Indoor',
      inStock: true,
    ),
    Product(
      id: '4',
      name: 'Lavender',
      description: 'Fragrant herb perfect for outdoor gardens',
      price: 12.99,
      imageUrl: '',
      category: 'Outdoor',
      inStock: true,
    ),
    Product(
      id: '5',
      name: 'Aloe Vera',
      description: 'Medicinal succulent with healing properties',
      price: 9.99,
      imageUrl: '',
      category: 'Succulent',
      inStock: true,
    ),
    Product(
      id: '6',
      name: 'Peace Lily',
      description: 'Elegant flowering plant that purifies air',
      price: 24.99,
      imageUrl: '',
      category: 'Indoor',
      inStock: true,
    ),
  ];

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _selectedCategory == 'All'
        ? _products
        : _products.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '0',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => context.push('/marketplace/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Indoor', 'Outdoor', 'Succulent', 'Herb'].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.white,
                  ),
                );
              }).toList(),
            ),
          ),
          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: filteredProducts[index],
                  onTap: () => context.push('/marketplace/product/${filteredProducts[index].id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

