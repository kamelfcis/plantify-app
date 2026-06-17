import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/glass_card.dart';
import '../../../../../../services/supabase_service.dart';
import '../../../../marketplace/presentation/models/product_model.dart';
import '../../../../marketplace/presentation/utils/product_search.dart';

class PlantSearchCard extends StatefulWidget {
  const PlantSearchCard({super.key});

  @override
  State<PlantSearchCard> createState() => _PlantSearchCardState();
}

class _PlantSearchCardState extends State<PlantSearchCard> {
  final _supabase = SupabaseService.instance;
  final _searchController = TextEditingController();

  List<Product> _allProducts = [];
  bool _loading = true;
  String? _error;
  String? _categoryHint;

  static const _quickFilters = [
    ('Indoor', Icons.home),
    ('Outdoor', Icons.wb_sunny),
    ('Succulent', Icons.local_florist),
    ('Herb', Icons.eco),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _supabase.getProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = data.map((e) => Product.fromMap(e)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Product> get _filtered {
    return ProductSearch.filter(
      _allProducts,
      query: _searchController.text,
      categoryHint: _categoryHint,
    );
  }

  void _openMarketplaceWithQuery() {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      context.push('/marketplace');
      return;
    }
    context.push(
      Uri(path: '/marketplace', queryParameters: {'q': q}).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final hasQuery = _searchController.text.trim().isNotEmpty ||
        (_categoryHint != null && _categoryHint!.isNotEmpty);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.search, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plant Search',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search shop plants by name or category',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _openMarketplaceWithQuery(),
            decoration: InputDecoration(
              hintText: 'Search plants...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    ),
                  IconButton(
                    icon: const Icon(Icons.storefront_outlined),
                    tooltip: 'Open in marketplace',
                    onPressed: _openMarketplaceWithQuery,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (label, icon) in _quickFilters)
                FilterChip(
                  avatar: Icon(icon, size: 18),
                  label: Text(label),
                  selected: _categoryHint == label,
                  onSelected: (selected) {
                    setState(() {
                      _categoryHint = selected ? label : null;
                    });
                  },
                ),
            ],
          ),
          if (_loading) ...[
            const SizedBox(height: 24),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          ] else if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              'Could not load plants. Pull to refresh the app or try again.',
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
            TextButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ] else if (hasQuery) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _openMarketplaceWithQuery,
                  child: const Text('See all in marketplace'),
                ),
              ],
            ),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No matching plants. Try different words or open the marketplace.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length.clamp(0, 6),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: p.imageUrl.isEmpty
                            ? Container(
                                color: AppColors.primary.withOpacity(0.15),
                                child: const Icon(Icons.local_florist),
                              )
                            : CachedNetworkImage(
                                imageUrl: p.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: AppColors.background,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: AppColors.primary.withOpacity(0.15),
                                  child: const Icon(Icons.broken_image_outlined),
                                ),
                              ),
                      ),
                    ),
                    title: Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${p.category} · \$${p.price.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push('/marketplace/product/${p.id}'),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}
