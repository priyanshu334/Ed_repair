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
    );
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
    final status = _orderData!.data['status'] as String? ?? 'Unknown';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
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
                      label: "Number", 
                      value: customer['phone']?.toString() ?? customer['number']?.toString() ?? 'N/A'
                    ),
                    _InfoRow(
                      label: "Address", 
                      value: customer['address']?.toString() ?? 'N/A'
                    ),
                    _InfoRow(
                      label: "Email", 
                      value: customer['email']?.toString() ?? 'N/A'
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
                      value: "₹${estimate['totalAmount']?.toString() ?? estimate['amount']?.toString() ?? 'N/A'}"
                    ),
                    _InfoRow(
                      label: "Advanced Paid", 
                      value: "₹${estimate['advancePaid']?.toString() ?? estimate['advance']?.toString() ?? 'N/A'}"
                    ),
                    _InfoRow(
                      label: "Remaining Amount", 
                      value: "₹${estimate['remainingAmount']?.toString() ?? 'N/A'}"
                    ),
                    _InfoRow(
                      label: "Due Date", 
                      value: estimate['dueDate']?.toString() ?? 'N/A'
                    ),
                    _InfoRow(
                      label: "Due Time", 
                      value: estimate['dueTime']?.toString() ?? 'N/A'
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
                      value: device['model']?.toString() ?? device['deviceModel']?.toString() ?? 'N/A'
                    ),
                    _InfoRow(
                      label: "Brand", 
                      value: device['brand']?.toString() ?? 'N/A'
                    ),
                    _InfoRow(
                      label: "IMEI", 
                      value: device['imei']?.toString() ?? 'N/A'
                    ),
                    _InfoRow(
                      label: "Lock Code", 
                      value: device['lockCode']?.toString() ?? device['passcode']?.toString() ?? 'N/A'
                    ),
                    _InfoRow(
                      label: "Pattern Lock", 
                      value: device['patternLock']?.toString() ?? device['pattern']?.toString() ?? 'N/A'
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
                            children: List.generate(4, (index) {
                              return Container(
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
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Problems List
                    if (device['problems'] != null)
                      _listSection(
                        title: "Problems List",
                        items: List<String>.from(device['problems'] as List? ?? []),
                        color: Colors.red[400]!,
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // Accessories List
                    if (device['accessories'] != null)
                      _listSection(
                        title: "Accessories List",
                        items: List<String>.from(device['accessories'] as List? ?? []),
                        color: Colors.blue[400]!,
                      ),
                    
                    const SizedBox(height: 16),
                    
                    if (device['warranty'] != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A4A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Device Warranty - ${device['warranty']?.toString() ?? 'N/A'}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D2D),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                icon: Icons.phone,
                label: "Call",
                color: Colors.green,
                onTap: () => _makeCall(customer['phone']?.toString() ?? customer['number']?.toString()),
              ),
              _actionButton(
                icon: Icons.chat,
                label: "WhatsApp",
                color: const Color(0xFF25D366),
                onTap: () => _openWhatsApp(customer['phone']?.toString() ?? customer['number']?.toString()),
              ),
              _actionButton(
                icon: Icons.message,
                label: "Message",
                color: Colors.blue,
                onTap: () => _sendMessage(customer['phone']?.toString() ?? customer['number']?.toString()),
              ),
              _actionButton(
                icon: Icons.print,
                label: "Print",
                color: Colors.orange,
                onTap: () => _printOrder(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
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

  void _makeCall(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Implement phone call functionality
      // You can use url_launcher package: launch("tel:$phoneNumber")
      print("Calling: $phoneNumber");
    }
  }

  void _openWhatsApp(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Implement WhatsApp functionality
      // You can use url_launcher package: launch("https://wa.me/$phoneNumber")
      print("Opening WhatsApp for: $phoneNumber");
    }
  }

  void _sendMessage(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Implement SMS functionality
      // You can use url_launcher package: launch("sms:$phoneNumber")
      print("Sending message to: $phoneNumber");
    }
  }

  void _printOrder() {
    // Implement print functionality
    print("Printing order: ${widget.orderId}");
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

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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