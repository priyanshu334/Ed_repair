import 'package:ed_repair/components/OrderCard.dart';
import 'package:flutter/material.dart';

class OrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  final Function(String) onViewOrder;
  final Function(String) onEditOrder;
  final Function(String) onDeleteOrder;
  final bool isLoading;
  final String? emptyMessage;

  // Dark theme colors
  static const Color textSecondary = Color(0xFF9CA3AF);

  const OrdersList({
    super.key,
    required this.orders,
    required this.onViewOrder,
    required this.onEditOrder,
    required this.onDeleteOrder,
    this.isLoading = false,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage ?? 'No orders found',
                style: TextStyle(
                  color: textSecondary.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or add a new order',
                style: TextStyle(
                  color: textSecondary.withOpacity(0.6),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onView: () => onViewOrder(order.id),
          onEdit: () => onEditOrder(order.id),
          onDelete: () => onDeleteOrder(order.id),
        );
      },
    );
  }
}