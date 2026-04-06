import 'package:flutter_test/flutter_test.dart';
import 'package:qhewtek/models/order.dart';

void main() {
  test('Order model parses nested order items', () {
    final order = Order.fromJson({
      'id': 101,
      'table_id': 6,
      'table_number': 6,
      'table_qr_code': 'TABLE-06',
      'status': 'pending',
      'total_price': 14.5,
      'created_at': '2026-04-06 18:05:00',
      'items': [
        {
          'id': 1,
          'menu_item_id': 3,
          'name': 'Iced Latte',
          'category': 'drinks',
          'quantity': 2,
          'price': 4.5,
          'subtotal': 9.0,
        },
      ],
    });

    expect(order.id, 101);
    expect(order.tableNumber, 6);
    expect(order.isPending, isTrue);
    expect(order.items, hasLength(1));
    expect(order.items.first.name, 'Iced Latte');
    expect(order.items.first.subtotal, 9.0);
  });
}
