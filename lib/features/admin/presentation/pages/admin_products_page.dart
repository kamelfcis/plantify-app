import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../services/supabase_service.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await SupabaseService.instance.getAllProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddProductDialog({Map<String, dynamic>? product}) {
    final isEdit = product != null;
    final nameController =
        TextEditingController(text: product?['name'] ?? '');
    final descController =
        TextEditingController(text: product?['description'] ?? '');
    final priceController =
        TextEditingController(text: product?['price']?.toString() ?? '');
    final stockController = TextEditingController(
        text: product?['stock_quantity']?.toString() ?? '0');
    String category = product?['category'] ?? 'Indoor';
    bool inStock = product?['in_stock'] ?? true;
    XFile? selectedImage;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEdit ? Icons.edit : Icons.add_box,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(isEdit ? 'Edit Product' : 'Add Product'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image picker
                  GestureDetector(
                    onTap: () async {
                      final image = await ImageHelper.pickImage(
                          source: ImageSource.gallery);
                      if (image != null) {
                        setDialogState(() => selectedImage = image);
                      }
                    },
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            )
                          : product?['image_url'] != null &&
                                  product!['image_url'].toString().isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: CachedNetworkImage(
                                    imageUrl: product['image_url'],
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (_, __, ___) =>
                                        _buildImagePlaceholder(),
                                  ),
                                )
                              : _buildImagePlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDialogField(nameController, 'Product Name',
                      Icons.local_florist),
                  const SizedBox(height: 12),
                  _buildDialogField(
                      descController, 'Description', Icons.description,
                      maxLines: 2),
                  const SizedBox(height: 12),
                  _buildDialogField(
                    priceController,
                    'Price (\$)',
                    Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildDialogField(
                    stockController,
                    'Stock Quantity',
                    Icons.inventory,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  // Category dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Category',
                        icon: Icon(Icons.category, color: AppColors.primary),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Indoor', child: Text('Indoor')),
                        DropdownMenuItem(
                            value: 'Outdoor', child: Text('Outdoor')),
                        DropdownMenuItem(
                            value: 'Succulent', child: Text('Succulent')),
                        DropdownMenuItem(value: 'Herb', child: Text('Herb')),
                        DropdownMenuItem(value: 'Tool', child: Text('Tool')),
                        DropdownMenuItem(
                            value: 'Accessory', child: Text('Accessory')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => category = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // In stock toggle
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SwitchListTile(
                      title: const Text('In Stock'),
                      value: inStock,
                      activeColor: AppColors.success,
                      onChanged: (val) {
                        setDialogState(() => inStock = val);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Name and price are required'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isUploading = true);

                      try {
                        String? imageUrl = product?['image_url'];

                        // Upload new image if selected
                        if (selectedImage != null) {
                          imageUrl = await SupabaseService.instance
                              .uploadProductImage(
                                  selectedImage!.path, selectedImage!.name);
                        }

                        if (isEdit) {
                          await SupabaseService.instance
                              .updateProduct(product!['id'], {
                            'name': nameController.text,
                            'description': descController.text,
                            'price': double.parse(priceController.text),
                            'category': category,
                            'image_url': imageUrl,
                            'in_stock': inStock,
                            'stock_quantity':
                                int.tryParse(stockController.text) ?? 0,
                          });
                        } else {
                          await SupabaseService.instance.createProduct(
                            name: nameController.text,
                            description: descController.text,
                            price: double.parse(priceController.text),
                            category: category,
                            imageUrl: imageUrl,
                            inStock: inStock,
                            stockQuantity:
                                int.tryParse(stockController.text) ?? 0,
                          );
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        _loadProducts();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit
                                  ? 'Product updated successfully'
                                  : 'Product added successfully'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isUploading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isUploading
                  ? 'Saving...'
                  : isEdit
                      ? 'Update'
                      : 'Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate,
            size: 40, color: AppColors.secondary),
        const SizedBox(height: 8),
        Text(
          'Tap to add image',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.background,
        ),
      ),
    );
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
        content: Text(
            'Are you sure you want to delete "${product['name']}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService.instance.deleteProduct(product['id']);
        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : _products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: AppColors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No products yet',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first product',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(_products[index]);
                      },
                    ),
                  ),
        // FAB
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddProductDialog(),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final imageUrl = product['image_url']?.toString() ?? '';
    final inStock = product['in_stock'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Container(
              width: 100,
              height: 110,
              color: AppColors.background,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.local_florist,
                        size: 40,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(
                      Icons.local_florist,
                      size: 40,
                      color: AppColors.accent,
                    ),
            ),
          ),
          // Product info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: inStock
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          inStock ? 'In Stock' : 'Out',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                inStock ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${product['category'] ?? ''} • Qty: ${product['stock_quantity'] ?? 0}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Action buttons
          Column(
            children: [
              IconButton(
                onPressed: () =>
                    _showAddProductDialog(product: product),
                icon: const Icon(Icons.edit, color: AppColors.info, size: 20),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _deleteProduct(product),
                icon:
                    const Icon(Icons.delete, color: AppColors.error, size: 20),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

