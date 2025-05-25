import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String customerName;
  final String status;
  final String dueDate;
  final String? serviceProvider;
  final String? serviceCenter;
  final String? imageUrl;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.status,
    required this.dueDate,
    this.serviceProvider,
    this.serviceCenter,
    this.imageUrl,
  });
}

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  // Dark theme colors
  static const Color primaryDark = Color(0xFF1F2937);
  static const Color secondaryDark = Color(0xFF374151);
  static const Color surfaceDark = Color(0xFF4B5563);
  static const Color cardDark = Color(0xFF374151);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color accent = Color(0xFF10B981);

  const OrderCard({
    super.key,
    required this.order,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'repaired':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.4),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Order',
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete Order ${order.id}? This action cannot be undone.',
            style: const TextStyle(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDelete != null) {
                  onDelete!();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order ${order.id} deleted successfully'),
                    backgroundColor: Colors.red[600],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Order Image
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: textSecondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: order.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          order.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image,
                              color: textSecondary,
                              size: 40,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        color: textSecondary,
                        size: 40,
                      ),
              ),
              const SizedBox(width: 16),
              
              // Order Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Id – ${order.id}',
                      style: const TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusChip(order.status),
                    const SizedBox(height: 8),
                    Text(
                      'Customer Name – ${order.customerName}',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due Date – ${order.dueDate}',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (order.serviceProvider != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Service Provider – ${order.serviceProvider}',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (order.serviceCenter != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Service Center – ${order.serviceCenter}',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onView,
                  icon: const Icon(
                    Icons.visibility,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(
                    Icons.delete,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}