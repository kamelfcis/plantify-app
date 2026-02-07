class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.inStock,
  });
}

class CartItem {
  final Product product;
  final int quantity;

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

