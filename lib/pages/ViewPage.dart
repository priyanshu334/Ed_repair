import 'package:ed_repair/components/BottomActionBar.dart';
import 'package:ed_repair/services/OrderService.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';

class ViewPage extends StatefulWidget {
  final String orderId;
  
  const ViewPage({super.key, required this.orderId});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final OrderService _orderService = OrderService();
  Document? _orderData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final order = await _orderService.getOrderById(widget.orderId);
      setState(() {
        _orderData = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load order: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 223, 223),
      appBar: AppBar(
        title: const Text(
          "View Orders",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrderData,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _orderData != null ? _buildBottomActionBar() : null,
    );
  }

  Widget _buildBottomActionBar() {
    final customer = _orderData!.data['customer'] as Map<String, dynamic>? ?? {};
    final phoneNumber = customer['phone']?.toString();
    
    return BottomActionBar(
      phoneNumber: phoneNumber,
      orderId: widget.orderId,
    );
  }

  void _customPrintHandler() {
    // Custom print logic if needed
    print("Custom print handler for order: ${widget.orderId}");
    // Add any additional print logic here
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2D2D2D)),
            SizedBox(height: 16),
            Text(
              "Loading order details...",
              style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D2D2D),
                foregroundColor: Colors.white,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_orderData == null) {
      return const Center(
        child: Text(
          "No order data found",
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 16,
          ),
        ),
      );
    }

    return _buildOrderContent();
  }

  Widget _buildOrderContent() {
    final customer = _orderData!.data['customer'] as Map<String, dynamic>? ?? {};
    final estimate = _orderData!.data['estimate'] as Map<String, dynamic>? ?? {};
    final device = _orderData!.data['device'] as Map<String, dynamic>? ?? {};
    final orderDetails = _orderData!.data['orderDetails'] as Map<String, dynamic>? ?? {};
    final engineer = _orderData!.data['engineer'] as Map<String, dynamic>? ?? {};
    final serviceCenter = _orderData!.data['serviceCenter'] as Map<String, dynamic>? ?? {};
    final status = _orderData!.data['status'] as String? ?? orderDetails['status'] as String? ?? 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Selected Customer
          _infoCard(
            title: "Selected Customer",
            icon: Icons.person_outline,
            children: [
              _InfoRow(
                label: "Name", 
                value: customer['name']?.toString() ?? 'N/A'
              ),
              _InfoRow(
                label: "Phone", 
                value: customer['phone']?.toString() ?? 'N/A'
              ),
              _InfoRow(
                label: "Address", 
                value: customer['address']?.toString() ?? 'N/A'
              ),
            ],
          ),

          // Service Center & Engineer
          _infoCard(
            title: "Service Details",
            icon: Icons.engineering_outlined,
            children: [
              _InfoRow(
                label: "Service Center", 
                value: serviceCenter['serviceCenter']?.toString() ?? 'N/A'
              ),
              _InfoRow(
                label: "Engineer", 
                value: engineer['engineer']?.toString() ?? 'N/A'
              ),
              _InfoRow(
                label: "Service Date", 
                value: _formatDate(engineer['date']?.toString())
              ),
              _InfoRow(
                label: "Service Time", 
                value: engineer['time']?.toString() ?? 'N/A'
              ),
            ],
          ),

          // Estimate Details
          _infoCard(
            title: "Estimate Details",
            icon: Icons.receipt_long_outlined,
            children: [
              _InfoRow(
                label: "Total Amount", 
                value: "₹${estimate['amount']?.toString() ?? 'N/A'}"
              ),
              _InfoRow(
                label: "Advanced Paid", 
                value: "₹${estimate['advancedPaid']?.toString() ?? 'N/A'}"
              ),
              _InfoRow(
                label: "Balance", 
                value: "₹${estimate['balance']?.toString() ?? 'N/A'}"
              ),
              _InfoRow(
                label: "Date", 
                value: _formatDate(estimate['date']?.toString())
              ),
              _InfoRow(
                label: "Time", 
                value: estimate['time']?.toString() ?? 'N/A'
              ),
              if (estimate['description'] != null)
                _InfoRow(
                  label: "Description", 
                  value: estimate['description']?.toString() ?? 'N/A'
                ),
            ],
          ),

          // Device KYC
          _infoCard(
            title: "Device KYC",
            icon: Icons.smartphone_outlined,
            children: [
              _InfoRow(
                label: "Device Model", 
                value: device['model']?.toString() ?? 'N/A'
              ),
              _InfoRow(
                label: "Lock Code", 
                value: device['lockCode']?.toString() ?? 'N/A'
              ),
              _InfoRow(
                label: "Warranty Status", 
                value: (device['isOnWarranty'] == true) ? 'Under Warranty' : 'No Warranty'
              ),
              if (device['warrantyDate'] != null)
                _InfoRow(
                  label: "Warranty Date", 
                  value: _formatDate(device['warrantyDate']?.toString())
                ),
              
              const SizedBox(height: 16),
              
              // Images Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Device Images",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImagePlaceholder("Front", device['frontImage']),
                        _buildImagePlaceholder("Back", device['backImage']),
                        _buildImagePlaceholder("Left", device['leftImage']),
                        _buildImagePlaceholder("Right", device['rightImage']),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Problems List
              if (device['problemsList'] != null)
                _listSection(
                  title: "Problems List",
                  items: List<String>.from(device['problemsList'] as List? ?? []),
                  color: Colors.red[400]!,
                ),
              
              const SizedBox(height: 12),
              
              // Standard Accessories List
              if (device['standardAccessories'] != null)
                _listSection(
                  title: "Standard Accessories",
                  items: List<String>.from(device['standardAccessories'] as List? ?? []),
                  color: Colors.blue[400]!,
                ),

              const SizedBox(height: 12),
              
              // Additional Accessories List
              if (device['additionalAccessories'] != null)
                _listSection(
                  title: "Additional Accessories",
                  items: List<String>.from(device['additionalAccessories'] as List? ?? []),
                  color: Colors.green[400]!,
                ),
            ],
          ),

          // Order Status
          _infoCard(
            title: "Order Status",
            icon: Icons.assignment_outlined,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(status).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(status), 
                      color: _getStatusColor(status), 
                      size: 20
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Status: ${status.toUpperCase()}",
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                label: "Order ID", 
                value: _orderData!.$id
              ),
              _InfoRow(
                label: "Created At", 
                value: _formatDateTime(_orderData!.data['createdAt']?.toString())
              ),
              _InfoRow(
                label: "Updated At", 
                value: _formatDateTime(_orderData!.data['updatedAt']?.toString())
              ),
              if (orderDetails['additionalNote'] != null)
                _InfoRow(
                  label: "Additional Notes", 
                  value: orderDetails['additionalNote']?.toString() ?? 'N/A'
                ),
              _InfoRow(
                label: "Order Complete", 
                value: (orderDetails['isComplete'] == true) ? 'Yes' : 'No'
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(String label, dynamic imageData) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey[600]!,
              width: 1,
            ),
          ),
          child: Icon(
            imageData != null ? Icons.image : Icons.image_outlined,
            color: imageData != null ? Colors.white70 : Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'in_progress':
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.yellow[700]!;
      case 'cancelled':
      case 'deleted':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Icons.check_circle_outline;
      case 'in_progress':
      case 'in progress':
        return Icons.pending_actions;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
      case 'deleted':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _listSection({
    required String title,
    required List<String> items,
    required Color color,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          BulletList(items: items, color: color),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BulletList extends StatelessWidget {
  final List<String> items;
  final Color? color;

  const BulletList({super.key, required this.items, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• ",
                      style: TextStyle(
                        color: color ?? Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: color ?? Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}