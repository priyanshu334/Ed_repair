import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EstimateDetailsForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;
  final Map<String, dynamic> initialData;

  const EstimateDetailsForm({
    super.key,
    required this.onFormChanged,
    required this.initialData,
  });

  @override
  State<EstimateDetailsForm> createState() => _EstimateDetailsFormState();
}

class _EstimateDetailsFormState extends State<EstimateDetailsForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _advancedPaidController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _advancedPaidFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  bool _isAmountFocused = false;
  bool _isAdvancedFocused = false;
  bool _isDescriptionFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _setupFocusListeners();
    _setupTextListeners();
  }

  void _initializeFormData() {
    // Initialize from passed data or defaults
    _amountController.text = widget.initialData['amount']?.toString() ?? '';
    _advancedPaidController.text = widget.initialData['advancedPaid']?.toString() ?? '';
    _descriptionController.text = widget.initialData['description']?.toString() ?? '';
    
    // Initialize date/time with current or provided values
    final now = DateTime.now();
    final initialDate = widget.initialData['date'] != null 
        ? DateTime.tryParse(widget.initialData['date']) ?? now
        : now;
    _dateController.text = DateFormat('yyyy-MM-dd').format(initialDate);
    
    final initialTime = widget.initialData['time'] != null
        ? DateFormat('h:mm a').parse(widget.initialData['time'])
        : now;
    _timeController.text = DateFormat('h:mm a').format(initialTime);
  }

  void _setupFocusListeners() {
    _amountFocus.addListener(() {
      setState(() => _isAmountFocused = _amountFocus.hasFocus);
    });

    _advancedPaidFocus.addListener(() {
      setState(() => _isAdvancedFocused = _advancedPaidFocus.hasFocus);
    });

    _descriptionFocus.addListener(() {
      setState(() => _isDescriptionFocused = _descriptionFocus.hasFocus);
    });
  }

  void _setupTextListeners() {
    _amountController.addListener(_notifyParent);
    _advancedPaidController.addListener(_notifyParent);
    _dateController.addListener(_notifyParent);
    _timeController.addListener(_notifyParent);
    _descriptionController.addListener(_notifyParent);
  }

  void _notifyParent() {
    widget.onFormChanged({
      'amount': _amountController.text.isNotEmpty 
          ? double.tryParse(_amountController.text) ?? 0 
          : 0,
      'advancedPaid': _advancedPaidController.text.isNotEmpty
          ? double.tryParse(_advancedPaidController.text) ?? 0
          : 0,
      'date': _dateController.text,
      'time': _timeController.text,
      'description': _descriptionController.text,
      'balance': _calculateBalance(),
    });
  }

  double _calculateBalance() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final advanced = double.tryParse(_advancedPaidController.text) ?? 0;
    return (amount - advanced).clamp(0, double.infinity);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _advancedPaidController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    
    _amountFocus.dispose();
    _advancedPaidFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_dateController.text)
          : DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF64B5F6),
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D2D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _timeController.text.isNotEmpty
          ? TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(_timeController.text))
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF64B5F6),
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D2D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year, 
        now.month, 
        now.day, 
        pickedTime.hour, 
        pickedTime.minute
      );
      
      setState(() {
        _timeController.text = DateFormat('h:mm a').format(dt);
      });
    }
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? prefixIcon,
    IconData? suffixIcon,
    FocusNode? focusNode,
    bool isFocused = false,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  if (isRequired) const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFF44336)),
                  ),
                ],
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
              filled: true,
              fillColor: isFocused ? const Color(0xFF404040) : const Color(0xFF3A3A3A),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: isFocused ? const Color(0xFF64B5F6) : const Color(0xFF9E9E9E),
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: const Color(0xFF9E9E9E),
                      size: 20,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF505050)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF505050)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: Color(0xFF64B5F6),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = _calculateBalance();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: balance > 0 ? const Color(0xFF3A2E1F) : const Color(0xFF1F3A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: balance > 0 ? const Color(0xFF6B4423) : const Color(0xFF4CAF50),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BALANCE SUMMARY',
            style: TextStyle(
              color: balance > 0 ? const Color(0xFFFFB74D) : const Color(0xFF81C784),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                balance > 0 ? 'Remaining Balance' : 'Payment Complete',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹${balance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: balance > 0 ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF404040), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.assessment,
                  color: Color(0xFF64B5F6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Estimate Details',
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
          _buildInputField(
            label: 'TOTAL AMOUNT',
            hint: 'Enter total amount',
            controller: _amountController,
            prefixIcon: Icons.currency_rupee,
            focusNode: _amountFocus,
            isFocused: _isAmountFocused,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isRequired: true,
          ),
          _buildInputField(
            label: 'ADVANCE PAYMENT',
            hint: 'Enter advance paid',
            controller: _advancedPaidController,
            prefixIcon: Icons.payment,
            focusNode: _advancedPaidFocus,
            isFocused: _isAdvancedFocused,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _buildBalanceCard(),
          _buildInputField(
            label: 'APPOINTMENT DATE',
            hint: 'Select date',
            controller: _dateController,
            readOnly: true,
            onTap: _selectDate,
            prefixIcon: Icons.calendar_today,
            suffixIcon: Icons.arrow_drop_down,
          ),
          _buildInputField(
            label: 'APPOINTMENT TIME',
            hint: 'Select time',
            controller: _timeController,
            readOnly: true,
            onTap: _selectTime,
            prefixIcon: Icons.access_time,
            suffixIcon: Icons.arrow_drop_down,
          ),
          _buildInputField(
            label: 'DESCRIPTION',
            hint: 'Add any additional details',
            controller: _descriptionController,
            focusNode: _descriptionFocus,
            isFocused: _isDescriptionFocused,
          ),
        ],
      ),
    );
  }
}