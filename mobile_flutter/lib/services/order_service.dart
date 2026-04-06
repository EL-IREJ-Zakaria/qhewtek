import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  const OrderService(this._apiService);

  final ApiService _apiService;

  Future<List<Order>> fetchOrders({String? status}) async {
    final response = await _apiService.get(
      '/orders',
      queryParameters: status == null ? null : {'status': status},
    );

    final rawOrders = response['data']?['orders'] as List<dynamic>? ?? [];

    return rawOrders
        .whereType<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList();
  }

  Future<void> confirmOrder(int orderId) async {
    await _apiService.post('/order/confirm', body: {'order_id': orderId});
  }

  Future<void> serveOrder(int orderId) async {
    await _apiService.post('/order/serve', body: {'order_id': orderId});
  }
}
