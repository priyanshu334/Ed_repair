import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EstimateDetailsForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;

  const EstimateDetailsForm({
    super.key,
    required this.onFormChanged,
  });

  @override
  State<EstimateDetailsForm> createState() => _EstimateDetailsFormState();
}

class _EstimateDetailsFormState extends State<EstimateDetailsForm> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController advancedPaidController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final FocusNode amountFocus = FocusNode();
  final FocusNode advancedPaidFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();

  bool _isAmountFocused = false;
  bool _isAdvancedFocused = false;
  bool _isDescriptionFocused = false;

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
    _setupTextListeners();
    
    // Initialize with current date and time
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    timeController.text = DateFormat('h:mm a').format(DateTime.now());
  }

  void _setupFocusListeners() {
    amountFocus.addListener(() {
      setState(() {
        _isAmountFocused = amountFocus.hasFocus;
      });
    });

    advancedPaidFocus.addListener(() {
      setState(() {
        _isAdvancedFocused = advancedPaidFocus.hasFocus;
      });
    });

    descriptionFocus.addListener(() {
      setState(() {
        _isDescriptionFocused = descriptionFocus.hasFocus;
      });
    });
  }

  void _setupTextListeners() {
    amountController.addListener(_notifyParent);
    advancedPaidController.addListener(_notifyParent);
    dateController.addListener(_notifyParent);
    timeController.addListener(_notifyParent);
    descriptionController.addListener(_notifyParent);
  }

  void _notifyParent() {
    widget.onFormChanged({
      'amount': amountController.text,
      'advancedPaid': advancedPaidController.text,
      'date': dateController.text,
      'time': timeController.text,
      'description': descriptionController.text,
      'balance': _calculateBalance().toString(),
    });
  }

  int _calculateBalance() {
    final amount = int.tryParse(amountController.text) ?? 0;
    final advanced = int.tryParse(advancedPaidController.text) ?? 0;
    return amount - advanced;
  }

  @override
  void dispose() {
    amountController.dispose();
    advancedPaidController.dispose();
    dateController.dispose();
    timeController.dispose();
    descriptionController.dispose();
    
    amountFocus.dispose();
    advancedPaidFocus.dispose();
    descriptionFocus.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Color(0xFF303030),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF202020),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Color(0xFF303030),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF202020),
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
        timeController.text = DateFormat('h:mm a').format(dt);
      });
    }
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? prefixIcon,
    IconData? suffixIcon,
    FocusNode? focusNode,
    bool isFocused = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: isFocused ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              onTap: onTap,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: const Color(0xFF2C2F30),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        color: isFocused ? const Color(0xFF4CAF50) : Colors.white60,
                      )
                    : null,
                suffixIcon: suffixIcon != null
                    ? Icon(
                        suffixIcon,
                        color: Colors.white60,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF4CAF50),
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance Summary',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Remaining Balance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_calculateBalance()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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
        color: const Color(0xFF232524),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estimate Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInputField(
            'TOTAL AMOUNT',
            'Enter amount to be paid',
            amountController,
            prefixIcon: Icons.attach_money,
            focusNode: amountFocus,
            isFocused: _isAmountFocused,
            keyboardType: TextInputType.number,
          ),
          _buildInputField(
            'ADVANCE PAYMENT',
            'Enter advance paid',
            advancedPaidController,
            prefixIcon: Icons.payments_outlined,
            focusNode: advancedPaidFocus,
            isFocused: _isAdvancedFocused,
            keyboardType: TextInputType.number,
          ),
          _buildBalanceCard(),
          _buildInputField(
            'APPOINTMENT DATE',
            'Select date',
            dateController,
            readOnly: true,
            onTap: _selectDate,
            prefixIcon: Icons.calendar_today,
            suffixIcon: Icons.arrow_drop_down,
          ),
          _buildInputField(
            'APPOINTMENT TIME',
            'Select time',
            timeController,
            readOnly: true,
            onTap: _selectTime,
            prefixIcon: Icons.access_time,
            suffixIcon: Icons.arrow_drop_down,
          ),
          _buildInputField(
            'DESCRIPTION (OPTIONAL)',
            'Add additional details',
            descriptionController,
            focusNode: descriptionFocus,
            isFocused: _isDescriptionFocused,
          ),
        ],
      ),
    );
  }
}