class OrderItem {
  const OrderItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.menuItemId,
    this.name = '',
    this.category = '',
    this.imageUrl,
  });

  final int id;
  final int? menuItemId;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final double subtotal;
  final String? imageUrl;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _asInt(json['id']),
      menuItemId: json['menu_item_id'] != null
          ? _asInt(json['menu_item_id'])
          : null,
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      quantity: _asInt(json['quantity']),
      price: _asDouble(json['price']),
      subtotal: _asDouble(json['subtotal']),
      imageUrl: json['image_url']?.toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? 0;
  }
}
