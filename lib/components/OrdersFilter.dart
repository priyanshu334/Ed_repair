import 'package:flutter/material.dart';

class OrdersFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> initialFilters;

  const OrdersFilter({
    super.key,
    required this.onFiltersChanged,
    this.initialFilters = const {},
  });

  @override
  State<OrdersFilter> createState() => _OrdersFilterState();
}

class _OrdersFilterState extends State<OrdersFilter> {
  bool showFilters = false;
  String selectedStatus = '';
  DateTime? selectedDueDate;
  
  // Advanced filter controllers
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController serviceProviderController = TextEditingController();
  final TextEditingController serviceCenterController = TextEditingController();

  // Dark theme colors
  static const Color primaryDark = Color(0xFF1F2937);
  static const Color secondaryDark = Color(0xFF374151);
  static const Color surfaceDark = Color(0xFF4B5563);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF374151);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color accent = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    if (widget.initialFilters.isNotEmpty) {
      selectedStatus = widget.initialFilters['status'] ?? '';
      customerNameController.text = widget.initialFilters['customerName'] ?? '';
      serviceProviderController.text = widget.initialFilters['serviceProvider'] ?? '';
      serviceCenterController.text = widget.initialFilters['serviceCenter'] ?? '';
      
      if (widget.initialFilters['dueDate'] != null) {
        selectedDueDate = widget.initialFilters['dueDate'];
        dueDateController.text = _formatDate(selectedDueDate!);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void selectStatus(String status) {
    setState(() {
      selectedStatus = status;
    });
    _applyFilters();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accent,
              onPrimary: Colors.white,
              surface: secondaryDark,
              onSurface: textPrimary,
            ),
            dialogBackgroundColor: primaryDark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = picked;
        dueDateController.text = _formatDate(picked);
      });
    }
  }

  void _applyFilters() {
    final filters = {
      'status': selectedStatus,
      'customerName': customerNameController.text,
      'dueDate': selectedDueDate,
      'serviceProvider': serviceProviderController.text,
      'serviceCenter': serviceCenterController.text,
    };
    widget.onFiltersChanged(filters);
  }

  void _clearFilters() {
    setState(() {
      selectedStatus = '';
      selectedDueDate = null;
      customerNameController.clear();
      dueDateController.clear();
      serviceProviderController.clear();
      serviceCenterController.clear();
    });
    _applyFilters();
  }

  void showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: surfaceDark, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Advanced Filters',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Customer Name Filter
                _buildFilterTextField(
                  controller: customerNameController,
                  hintText: 'Search by Customer name',
                ),
                
                // Due Date Filter with Date Picker
                _buildDateFilterField(),
                
                // Service Provider Filter
                _buildFilterTextField(
                  controller: serviceProviderController,
                  hintText: 'Search by Service Provider',
                ),
                
                // Service Center Filter
                _buildFilterTextField(
                  controller: serviceCenterController,
                  hintText: 'Search by Service Center',
                ),
                
                const SizedBox(height: 24),
                
                // Search Button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _applyFilters();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: textSecondary),
          filled: true,
          fillColor: secondaryDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: surfaceDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: surfaceDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: accent),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: dueDateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        style: const TextStyle(color: textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by due date',
          hintStyle: const TextStyle(color: textSecondary),
          filled: true,
          fillColor: secondaryDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: surfaceDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: surfaceDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: accent),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: const Icon(Icons.calendar_today, color: accent),
        ),
      ),
    );
  }

  Widget buildStatusButton(String label) {
    final isSelected = selectedStatus == label;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => selectStatus(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? accent : surfaceDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: isSelected ? 3 : 1,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filters Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: secondaryDark,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: surfaceDark),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Filters',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    showFilters ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: textPrimary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Filter Section
        if (showFilters)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: surfaceDark),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Status',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      buildStatusButton('Pending'),
                      buildStatusButton('Repaired'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      buildStatusButton('Delivered'),
                      buildStatusButton('Cancelled'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: showAdvancedFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: textSecondary.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune,
                                color: textPrimary,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Advanced filters',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          elevation: 2,
                        ),
                        onPressed: _applyFilters,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Search',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    customerNameController.dispose();
    dueDateController.dispose();
    serviceProviderController.dispose();
    serviceCenterController.dispose();
    super.dispose();
  }
}