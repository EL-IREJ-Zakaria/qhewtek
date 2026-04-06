import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = orderProvider.orders;
        final pending = orders.where((order) => order.isPending).length;
        final confirmed = orders.where((order) => order.isConfirmed).length;
        final served = orders.where((order) => order.isServed).length;

        return RefreshIndicator(
          onRefresh: orderProvider.loadOrders,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatusSummaryCard(
                      label: 'Pending',
                      value: '$pending',
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusSummaryCard(
                      label: 'Confirmed',
                      value: '$confirmed',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusSummaryCard(
                      label: 'Served',
                      value: '$served',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              if (orderProvider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Backend connection issue'),
                    subtitle: Text(orderProvider.errorMessage!),
                    trailing: TextButton(
                      onPressed: orderProvider.loadOrders,
                      child: const Text('Retry'),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (orders.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No active orders yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Once a customer scans a table QR code and places an order, it will appear here automatically.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: OrderCard(
                      order: order,
                      isProcessing: orderProvider.processingOrderIds.contains(
                        order.id,
                      ),
                      onConfirm: order.isPending
                          ? () async {
                              await orderProvider.confirmOrder(order.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order confirmed.'),
                                  ),
                                );
                              }
                            }
                          : null,
                      onServe: order.isConfirmed
                          ? () async {
                              await orderProvider.serveOrder(order.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order marked as served.'),
                                  ),
                                );
                              }
                            }
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusSummaryCard extends StatelessWidget {
  const _StatusSummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 16),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
