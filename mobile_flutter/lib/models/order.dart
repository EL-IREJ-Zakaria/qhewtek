import 'order_item.dart';

class Order {
  const Order({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.tableQrCode,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final int tableId;
  final int tableNumber;
  final String tableQrCode;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final List<OrderItem> items;

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isServed => status == 'served';

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return Order(
      id: _asInt(json['id']),
      tableId: _asInt(json['table_id']),
      tableNumber: _asInt(json['table_number']),
      tableQrCode: (json['table_qr_code'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      totalPrice: _asDouble(json['total_price']),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItem.fromJson)
          .toList(),
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
