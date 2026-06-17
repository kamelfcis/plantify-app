import '../models/product_model.dart';

/// Case-insensitive search over marketplace [Product] fields.
class ProductSearch {
  ProductSearch._();

  static bool matches(
    Product p, {
    required String query,
    String? categoryHint,
  }) {
    if (categoryHint != null && categoryHint.isNotEmpty) {
      final h = categoryHint.toLowerCase();
      final hitsHint = p.category.toLowerCase().contains(h) ||
          p.name.toLowerCase().contains(h);
      if (!hitsHint) return false;
    }
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return p.name.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q);
  }

  static List<Product> filter(
    List<Product> products, {
    required String query,
    String? categoryHint,
  }) {
    return products
        .where(
          (p) => matches(p, query: query, categoryHint: categoryHint),
        )
        .toList();
  }
}
