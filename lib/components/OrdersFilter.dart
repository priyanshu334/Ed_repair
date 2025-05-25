import 'package:ed_repair/pages/ManageEnginner.dart';
import 'package:ed_repair/services/ServiceCenterService.dart';
import 'package:ed_repair/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
// Import your services


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
  List<String> selectedStatuses = []; // Changed to List for multi-select
  DateTime? selectedDueDate;
  
  // Advanced filter controllers - now for dropdowns
  final TextEditingController dueDateController = TextEditingController();
  
  // Selected values for dropdowns
  String? selectedCustomerId;
  String? selectedCustomerName;
  String? selectedEngineerId;
  String? selectedEngineerName;
  String? selectedServiceCenterId;
  String? selectedServiceCenterName;
  
  // Data lists
  List<Document> customers = [];
  List<Document> engineers = [];
  List<Document> serviceCenters = [];
  
  // Loading states
  bool isLoadingCustomers = false;
  bool isLoadingEngineers = false;
  bool isLoadingServiceCenters = false;
  
  // Services
  final CustomerService customerService = CustomerService();
  final EngineerService engineerService = EngineerService();
  final ServiceCenterService serviceCenterService = ServiceCenterService();

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
    _loadAllData();
  }

  void _initializeFilters() {
    if (widget.initialFilters.isNotEmpty) {
      // Handle multi-select status
      if (widget.initialFilters['statuses'] != null) {
        selectedStatuses = List<String>.from(widget.initialFilters['statuses']);
      }
      
      selectedCustomerId = widget.initialFilters['customerId'];
      selectedCustomerName = widget.initialFilters['customerName'];
      selectedEngineerId = widget.initialFilters['engineerId'];
      selectedEngineerName = widget.initialFilters['engineerName'];
      selectedServiceCenterId = widget.initialFilters['serviceCenterId'];
      selectedServiceCenterName = widget.initialFilters['serviceCenterName'];
      
      if (widget.initialFilters['dueDate'] != null) {
        selectedDueDate = widget.initialFilters['dueDate'];
        dueDateController.text = _formatDate(selectedDueDate!);
      }
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadCustomers(),
      _loadEngineers(),
      _loadServiceCenters(),
    ]);
  }

  Future<void> _loadCustomers() async {
    setState(() => isLoadingCustomers = true);
    try {
      customers = await customerService.getAllCustomers();
    } catch (e) {
      print('Error loading customers: $e');
    } finally {
      setState(() => isLoadingCustomers = false);
    }
  }

  Future<void> _loadEngineers() async {
    setState(() => isLoadingEngineers = true);
    try {
      engineers = await engineerService.getAllEngineers();
    } catch (e) {
      print('Error loading engineers: $e');
    } finally {
      setState(() => isLoadingEngineers = false);
    }
  }

  Future<void> _loadServiceCenters() async {
    setState(() => isLoadingServiceCenters = true);
    try {
      serviceCenters = await serviceCenterService.getAllServiceCenters();
    } catch (e) {
      print('Error loading service centers: $e');
    } finally {
      setState(() => isLoadingServiceCenters = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void toggleStatus(String status) {
    setState(() {
      if (selectedStatuses.contains(status)) {
        selectedStatuses.remove(status);
      } else {
        selectedStatuses.add(status);
      }
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
      'statuses': selectedStatuses,
      'customerId': selectedCustomerId,
      'customerName': selectedCustomerName,
      'dueDate': selectedDueDate,
      'engineerId': selectedEngineerId,
      'engineerName': selectedEngineerName,
      'serviceCenterId': selectedServiceCenterId,
      'serviceCenterName': selectedServiceCenterName,
    };
    widget.onFiltersChanged(filters);
  }

  void _clearFilters() {
    setState(() {
      selectedStatuses.clear();
      selectedDueDate = null;
      selectedCustomerId = null;
      selectedCustomerName = null;
      selectedEngineerId = null;
      selectedEngineerName = null;
      selectedServiceCenterId = null;
      selectedServiceCenterName = null;
      dueDateController.clear();
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
                
                // Customer Dropdown
                _buildCustomerDropdown(),
                
                // Due Date Filter with Date Picker
                _buildDateFilterField(),
                
                // Engineer Dropdown
                _buildEngineerDropdown(),
                
                // Service Center Dropdown
                _buildServiceCenterDropdown(),
                
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

  Widget _buildCustomerDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedCustomerId,
        decoration: InputDecoration(
          hintText: 'Select Customer',
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
        dropdownColor: secondaryDark,
        style: const TextStyle(color: textPrimary),
        icon: isLoadingCustomers 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            )
          : const Icon(Icons.arrow_drop_down, color: textPrimary),
        items: customers.map((customer) {
          return DropdownMenuItem<String>(
            value: customer.$id,
            child: Text(
              customer.data['name'] ?? 'Unknown',
              style: const TextStyle(color: textPrimary),
            ),
          );
        }).toList(),
        onChanged: isLoadingCustomers ? null : (String? value) {
          setState(() {
            selectedCustomerId = value;
            selectedCustomerName = value != null 
              ? customers.firstWhere((c) => c.$id == value).data['name']
              : null;
          });
        },
      ),
    );
  }

  Widget _buildEngineerDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedEngineerId,
        decoration: InputDecoration(
          hintText: 'Select Service Provider',
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
        dropdownColor: secondaryDark,
        style: const TextStyle(color: textPrimary),
        icon: isLoadingEngineers 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            )
          : const Icon(Icons.arrow_drop_down, color: textPrimary),
        items: engineers.map((engineer) {
          return DropdownMenuItem<String>(
            value: engineer.$id,
            child: Text(
              engineer.data['name'] ?? 'Unknown',
              style: const TextStyle(color: textPrimary),
            ),
          );
        }).toList(),
        onChanged: isLoadingEngineers ? null : (String? value) {
          setState(() {
            selectedEngineerId = value;
            selectedEngineerName = value != null 
              ? engineers.firstWhere((e) => e.$id == value).data['name']
              : null;
          });
        },
      ),
    );
  }

  Widget _buildServiceCenterDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedServiceCenterId,
        decoration: InputDecoration(
          hintText: 'Select Service Center',
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
        dropdownColor: secondaryDark,
        style: const TextStyle(color: textPrimary),
        icon: isLoadingServiceCenters 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            )
          : const Icon(Icons.arrow_drop_down, color: textPrimary),
        items: serviceCenters.map((serviceCenter) {
          return DropdownMenuItem<String>(
            value: serviceCenter.$id,
            child: Text(
              serviceCenter.data['name'] ?? 'Unknown',
              style: const TextStyle(color: textPrimary),
            ),
          );
        }).toList(),
        onChanged: isLoadingServiceCenters ? null : (String? value) {
          setState(() {
            selectedServiceCenterId = value;
            selectedServiceCenterName = value != null 
              ? serviceCenters.firstWhere((sc) => sc.$id == value).data['name']
              : null;
          });
        },
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
    final isSelected = selectedStatuses.contains(label);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => toggleStatus(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? accent : surfaceDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: isSelected ? 3 : 1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check, size: 16),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
                  Text(
                    selectedStatuses.isNotEmpty 
                      ? 'Filters (${selectedStatuses.length})'
                      : 'Filters',
                    style: const TextStyle(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by Status',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selectedStatuses.isNotEmpty)
                        Text(
                          '${selectedStatuses.length} selected',
                          style: const TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
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
    dueDateController.dispose();
    super.dispose();
  }
}