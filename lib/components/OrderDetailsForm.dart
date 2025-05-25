import 'package:flutter/material.dart';

class OrderDetailsForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onOrderChanged;

  const OrderDetailsForm({
    super.key,
    required this.onOrderChanged,
  });

  @override
  State<OrderDetailsForm> createState() => _OrderDetailsFormState();
}

class _OrderDetailsFormState extends State<OrderDetailsForm> {
  String? _selectedStatus;
  String _additionalNote = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 22, 23, 26),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: const Color(0xFF2A2D36),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color.fromARGB(255, 49, 121, 65),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Order Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Status Field
          const Text(
            'Order Status',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdownField(),
          
          const SizedBox(height: 20),
          
          // Additional Note Field
          const Text(
            'Additional Note',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildNoteField(),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          isCollapsed: true,
        ),
        dropdownColor: const Color(0xFF2A2D36),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF61DAFB)),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        hint: const Text('Select status', style: TextStyle(color: Colors.white70)),
        value: _selectedStatus,
        items: ['Processing', 'Shipped', 'Delivered', 'Cancelled']
            .map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedStatus = value;
          });
          _notifyParent();
        },
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: TextFormField(
        maxLines: 3,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Enter any additional notes here...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          _additionalNote = value;
          _notifyParent();
        },
      ),
    );
  }

  void _notifyParent() {
    final orderData = {
      'status': _selectedStatus,
      'additionalNote': _additionalNote,
      'isComplete': _selectedStatus != null && _additionalNote.isNotEmpty,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    widget.onOrderChanged(orderData);
  }
}