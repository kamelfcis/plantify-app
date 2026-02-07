class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool inStock;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.inStock,
    this.stockQuantity = 0,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] ?? '',
      category: map['category'] ?? '',
      inStock: map['in_stock'] ?? true,
      stockQuantity: map['stock_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
    };
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final String status;
  final bool isGift;
  final GiftInfo? giftInfo;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    required this.status,
    this.isGift = false,
    this.giftInfo,
  });
}

class GiftInfo {
  final String receiverName;
  final String receiverEmail;
  final String receiverAddress;
  final String message;

  GiftInfo({
    required this.receiverName,
    required this.receiverEmail,
    required this.receiverAddress,
    required this.message,
  });
}
