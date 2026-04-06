import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.isProcessing,
    this.onConfirm,
    this.onServe,
  });

  final Order order;
  final bool isProcessing;
  final VoidCallback? onConfirm;
  final VoidCallback? onServe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = switch (order.status) {
      'confirmed' => colorScheme.primary,
      'served' => Colors.green,
      _ => colorScheme.secondary,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table ${order.tableNumber}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Order #${order.id} • ${DateFormat('MMM d, h:mm a').format(order.createdAt.toLocal())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: order.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity} × ${item.name}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                symbol: '\$',
                              ).format(item.subtotal),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  Icons.table_restaurant_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('QR ${order.tableQrCode}'),
                const Spacer(),
                Text(
                  NumberFormat.currency(symbol: '\$').format(order.totalPrice),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (onConfirm != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isProcessing ? null : onConfirm,
                      icon: isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Confirm'),
                    ),
                  ),
                if (onConfirm != null && onServe != null)
                  const SizedBox(width: 12),
                if (onServe != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isProcessing ? null : onServe,
                      icon: const Icon(Icons.room_service_outlined),
                      label: const Text('Mark Served'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
