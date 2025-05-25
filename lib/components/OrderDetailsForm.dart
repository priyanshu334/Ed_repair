import 'package:flutter/material.dart';

class OrderDetailsForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onOrderChanged;
  final Map<String, dynamic> initialData;

  const OrderDetailsForm({
    super.key,
    required this.onOrderChanged,
    required this.initialData,
  });

  @override
  State<OrderDetailsForm> createState() => _OrderDetailsFormState();
}

class _OrderDetailsFormState extends State<OrderDetailsForm> {
  late String _selectedStatus;
  late String _notes;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    // Initialize from passed data with proper fallbacks
    _selectedStatus = widget.initialData['status']?.toString() ?? 'pending';
    _notes = widget.initialData['notes']?.toString() ?? '';
    _notesController = TextEditingController(text: _notes);
  }

  @override
  void didUpdateWidget(OrderDetailsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the form when initialData changes
    if (widget.initialData != oldWidget.initialData) {
      final newStatus = widget.initialData['status']?.toString() ?? 'pending';
      final newNotes = widget.initialData['notes']?.toString() ?? '';
      
      if (newStatus != _selectedStatus || newNotes != _notes) {
        setState(() {
          _selectedStatus = newStatus;
          _notes = newNotes;
          _notesController.text = newNotes;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFF404040), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF505050), width: 1),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF64B5F6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Order Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Status Field
          const Text(
            'Order Status*',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _buildStatusDropdown(),
          
          const SizedBox(height: 20),
          
          // Notes Field
          const Text(
            'Notes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _buildNotesField(),
          
          const SizedBox(height: 20),
          
          // Order Information Display (if available)
          if (widget.initialData.containsKey('orderId') || 
              widget.initialData.containsKey('createdAt') ||
              widget.initialData.containsKey('updatedAt'))
            _buildOrderInfo(),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    const statusOptions = {
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'in_progress': 'In Progress',
      'diagnosis': 'Under Diagnosis',
      'waiting_approval': 'Waiting for Approval',
      'repair_in_progress': 'Repair in Progress',
      'quality_check': 'Quality Check',
      'completed': 'Completed',
      'ready_for_pickup': 'Ready for Pickup',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      'on_hold': 'On Hold',
    };

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF505050)),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        dropdownColor: const Color(0xFF3A3A3A),
        value: statusOptions.containsKey(_selectedStatus) ? _selectedStatus : 'pending',
        items: statusOptions.entries
            .map((entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      _getStatusIcon(entry.key),
                      const SizedBox(width: 10),
                      Text(
                        entry.value,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedStatus = value);
            _notifyParent();
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an order status';
          }
          return null;
        },
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'pending':
        iconData = Icons.schedule;
        iconColor = const Color(0xFFFF9800);
        break;
      case 'confirmed':
        iconData = Icons.check_circle_outline;
        iconColor = const Color(0xFF64B5F6);
        break;
      case 'in_progress':
      case 'diagnosis':
      case 'repair_in_progress':
        iconData = Icons.build;
        iconColor = const Color(0xFF64B5F6);
        break;
      case 'waiting_approval':
        iconData = Icons.pause_circle_outline;
        iconColor = const Color(0xFFFFC107);
        break;
      case 'quality_check':
        iconData = Icons.verified;
        iconColor = const Color(0xFFAB47BC);
        break;
      case 'completed':
      case 'ready_for_pickup':
      case 'delivered':
        iconData = Icons.check_circle;
        iconColor = const Color(0xFF4CAF50);
        break;
      case 'cancelled':
        iconData = Icons.cancel;
        iconColor = const Color(0xFFF44336);
        break;
      case 'on_hold':
        iconData = Icons.pause;
        iconColor = const Color(0xFF9E9E9E);
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = const Color(0xFF9E9E9E);
    }

    return Icon(iconData, color: iconColor, size: 18);
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      maxLength: 500,
      style: const TextStyle(fontSize: 15, color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter any notes about this order (repair instructions, customer requests, etc.)',
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: const Color(0xFF3A3A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF505050)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF505050)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
        ),
        counterText: '${_notes.length}/500',
        counterStyle: TextStyle(
          color: _notes.length > 450 ? const Color(0xFFF44336) : const Color(0xFF9E9E9E),
          fontSize: 12,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _notes = value;
        });
        _notifyParent();
      },
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF505050)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          if (widget.initialData.containsKey('orderId'))
            _buildInfoRow('Order ID', widget.initialData['orderId'].toString()),
          
          if (widget.initialData.containsKey('createdAt'))
            _buildInfoRow('Created', _formatDateTime(widget.initialData['createdAt'])),
          
          if (widget.initialData.containsKey('updatedAt'))
            _buildInfoRow('Last Updated', _formatDateTime(widget.initialData['updatedAt'])),
          
          if (widget.initialData.containsKey('priority'))
            _buildInfoRow('Priority', widget.initialData['priority'].toString().toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFBDBDBD),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic dateTime) {
    try {
      DateTime dt;
      if (dateTime is String) {
        dt = DateTime.parse(dateTime);
      } else if (dateTime is DateTime) {
        dt = dateTime;
      } else {
        return dateTime.toString();
      }
      
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime.toString();
    }
  }

  void _notifyParent() {
    final orderData = {
      'status': _selectedStatus,
      'notes': _notes.trim(),
    };
    
    // Include any additional data that was in initialData but not editable
    final additionalData = Map<String, dynamic>.from(widget.initialData);
    additionalData.removeWhere((key, value) => orderData.containsKey(key));
    
    widget.onOrderChanged({
      ...additionalData,
      ...orderData,
    });
  }
}