import 'package:ed_repair/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;

  Customer({
    required this.id, 
    required this.name, 
    required this.phone, 
    required this.address
  });

  factory Customer.fromDocument(Document doc) {
    return Customer(
      id: doc.$id,
      name: doc.data['name'] ?? '',
      phone: doc.data['phone'] ?? '',
      address: doc.data['address'] ?? '',
    );
  }

  // Create a copy with updated fields
  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  // Convert to map with basic info only
  Map<String, String> toBasicInfo() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}

class SelectCustomerBox extends StatefulWidget {
  final Function(Map<String, String>?) onCustomerChanged; // Now passes basic info map or null
  final Customer? initialCustomer;

  const SelectCustomerBox({
    super.key, 
    required this.onCustomerChanged,
    this.initialCustomer,
  });

  @override
  State<SelectCustomerBox> createState() => _SelectCustomerBoxState();
}

class _SelectCustomerBoxState extends State<SelectCustomerBox> {
  final CustomerService _customerService = CustomerService();
  List<Customer> _allCustomers = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.initialCustomer;
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final documents = await _customerService.getAllCustomers();
      setState(() {
        _allCustomers = documents.map((doc) => Customer.fromDocument(doc)).toList();
        _isLoading = false;
        
        // If initial customer was provided, ensure it's in our list
        if (widget.initialCustomer != null) {
          final exists = _allCustomers.any((c) => c.id == widget.initialCustomer!.id);
          if (!exists) {
            _allCustomers.add(widget.initialCustomer!);
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading customers: $e')),
        );
      }
    }
  }

  void _showCustomerSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomerSelectionDialog(
        customers: _allCustomers,
        customerService: _customerService,
        selectedCustomer: _selectedCustomer,
        onSelectCustomer: (customer) {
          setState(() {
            _selectedCustomer = customer;
          });
          // Pass only basic customer info (name, phone, address) to parent
          widget.onCustomerChanged(customer.toBasicInfo());
        },
        onRefresh: _loadCustomers,
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedCustomer = null;
    });
    // Pass null to parent to clear selection
    widget.onCustomerChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 247, 247, 247),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Customer Info Card (shown when customer is selected)
            if (_selectedCustomer != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF2196F3),
                          radius: 20,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedCustomer!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Selected Customer',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _clearSelection,
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          tooltip: 'Clear selection',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedCustomer!.phone.isEmpty 
                                      ? 'No phone number' 
                                      : _selectedCustomer!.phone,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _selectedCustomer!.phone.isEmpty 
                                        ? Colors.grey.shade500 
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedCustomer!.address.isEmpty 
                                      ? 'No address provided' 
                                      : _selectedCustomer!.address,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _selectedCustomer!.address.isEmpty 
                                        ? Colors.grey.shade500 
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Selection Button
            InkWell(
              onTap: _isLoading ? null : _showCustomerSelectionDialog,
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isLoading 
                          ? 'Loading...' 
                          : (_selectedCustomer != null 
                              ? 'Change Customer' 
                              : 'Select Customer'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!_isLoading) const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerSelectionDialog extends StatefulWidget {
  final List<Customer> customers;
  final CustomerService customerService;
  final Function(Customer) onSelectCustomer;
  final VoidCallback onRefresh;
  final Customer? selectedCustomer;

  const CustomerSelectionDialog({
    super.key,
    required this.customers,
    required this.customerService,
    required this.onSelectCustomer,
    required this.onRefresh,
    this.selectedCustomer,
  });

  @override
  State<CustomerSelectionDialog> createState() => _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends State<CustomerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];
  Customer? _selectedCustomer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
    _selectedCustomer = widget.selectedCustomer;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _filteredCustomers = widget.customers;
        _isSearching = false;
      });
      return;
    }

    _performSearch();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final documents = await widget.customerService.searchCustomersByName(query);
      setState(() {
        _filteredCustomers = documents.map((doc) => Customer.fromDocument(doc)).toList();
        _isSearching = false;
      });
    } catch (e) {
      final localFiltered = widget.customers.where((customer) {
        return customer.name.toLowerCase().contains(query.toLowerCase()) ||
            customer.phone.toLowerCase().contains(query.toLowerCase()) ||
            customer.address.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      setState(() {
        _filteredCustomers = localFiltered;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ContentBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Customer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.onRefresh();
                    setState(() {
                      _filteredCustomers = widget.customers;
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh customers',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or address...',
                prefixIcon: _isSearching 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: _filteredCustomers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isEmpty 
                                  ? 'No customers found' 
                                  : 'No customers match your search',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return CustomerTile(
                          customer: customer,
                          isSelected: _selectedCustomer?.id == customer.id,
                          onTap: () {
                            setState(() {
                              _selectedCustomer = customer;
                            });
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedCustomer == null
                      ? null
                      : () {
                          widget.onSelectCustomer(_selectedCustomer!);
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('DONE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerTile extends StatelessWidget {
  final Customer customer;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomerTile({
    super.key,
    required this.customer,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
        child: Icon(
          Icons.person,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
      title: Text(
        customer.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.phone),
          Text(
            customer.address,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
      tileColor: isSelected ? Colors.grey.shade100 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class ContentBox extends StatelessWidget {
  final Widget child;

  const ContentBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}