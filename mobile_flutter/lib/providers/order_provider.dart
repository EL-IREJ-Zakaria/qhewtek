import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderService);

  final OrderService _orderService;
  final Set<int> _processingOrderIds = <int>{};

  List<Order> _orders = const [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;
  Set<int> _knownPendingOrders = <int>{};
  bool _hasLoadedOnce = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<int> get processingOrderIds => _processingOrderIds;

  Future<void> loadOrders({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final nextOrders = await _orderService.fetchOrders();
      final nextPendingOrders = nextOrders
          .where((order) => order.isPending)
          .map((order) => order.id)
          .toSet();

      if (_hasLoadedOnce &&
          nextPendingOrders.difference(_knownPendingOrders).isNotEmpty) {
        SystemSound.play(SystemSoundType.alert);
      }

      _orders = nextOrders;
      _knownPendingOrders = nextPendingOrders;
      _errorMessage = null;
      _hasLoadedOnce = true;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startPolling() {
    if (_pollingTimer != null) {
      return;
    }

    loadOrders();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => loadOrders(silent: true),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> confirmOrder(int orderId) async {
    await _runOrderAction(orderId, () => _orderService.confirmOrder(orderId));
  }

  Future<void> serveOrder(int orderId) async {
    await _runOrderAction(orderId, () => _orderService.serveOrder(orderId));
  }

  Future<void> _runOrderAction(
    int orderId,
    Future<void> Function() action,
  ) async {
    _processingOrderIds.add(orderId);
    notifyListeners();

    try {
      await action();
      await loadOrders(silent: true);
    } finally {
      _processingOrderIds.remove(orderId);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
