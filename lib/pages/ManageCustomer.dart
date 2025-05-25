import 'package:ed_repair/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
 // Import your CustomerService

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final CustomerService _customerService = CustomerService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Document> _customers = [];
  List<Document> _filteredCustomers = [];
  bool _isLoading = false;
  String? _editingCustomerId;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        final name = customer.data['name'].toString().toLowerCase();
        final phone = customer.data['phone'].toString().toLowerCase();
        final address = customer.data['address'].toString().toLowerCase();
        return name.contains(query) || phone.contains(query) || address.contains(query);
      }).toList();
    });
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await _customerService.getAllCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
      });
    } catch (e) {
      _showError('Failed to load customers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addOrUpdateCustomer() async {
    if (_nameController.text.isEmpty || 
        _phoneController.text.isEmpty || 
        _addressController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_editingCustomerId != null) {
        // Update existing customer
        await _customerService.updateCustomer(
          documentId: _editingCustomerId!,
          name: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        );
        _showSuccess('Customer updated successfully');
      } else {
        // Add new customer
        await _customerService.addCustomer(
          name: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        );
        _showSuccess('Customer added successfully');
      }
      
      _clearForm();
      await _loadCustomers();
    } catch (e) {
      _showError('Failed to save customer: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCustomer(String documentId) async {
    final confirmed = await _showConfirmDialog('Delete Customer', 
        'Are you sure you want to delete this customer?');
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await _customerService.deleteCustomer(documentId);
      _showSuccess('Customer deleted successfully');
      await _loadCustomers();
    } catch (e) {
      _showError('Failed to delete customer: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _editCustomer(Document customer) {
    setState(() {
      _editingCustomerId = customer.$id;
      _nameController.text = customer.data['name'] ?? '';
      _phoneController.text = customer.data['phone'] ?? '';
      _addressController.text = customer.data['address'] ?? '';
    });
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() => _editingCustomerId = null);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2538),
      appBar: AppBar(
        title: const Text(
          'Manage Customer',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          const Icon(Icons.notifications_outlined, size: 20),
          const SizedBox(width: 16),
          const Icon(Icons.menu, size: 20),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 34, 37, 43),
              Color.fromARGB(255, 26, 28, 31),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'Manage Customer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Image.asset(
                          'assets/images/img6.png',
                          height: 140,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Search bar with functionality
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search Customer',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(height: 24),
                      
                      // Form fields
                      const Text(
                        'Customer Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Customer Number',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Customer Address',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_editingCustomerId != null) ...[
                            Container(
                              height: 36,
                              width: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: InkWell(
                                onTap: _clearForm,
                                child: const Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          Container(
                            height: 36,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: InkWell(
                              onTap: _isLoading ? null : _addOrUpdateCustomer,
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF1A2538),
                                        ),
                                      )
                                    : Text(
                                        _editingCustomerId != null ? 'Update' : 'Add',
                                        style: const TextStyle(
                                          color: Color(0xFF1A2538),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            
            // Customer list section
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customers (${_filteredCustomers.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: _loadCustomers,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredCustomers.isEmpty
                            ? Center(
                                child: Text(
                                  _customers.isEmpty 
                                      ? 'No customers found' 
                                      : 'No customers match your search',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredCustomers.length,
                                itemBuilder: (context, index) {
                                  final customer = _filteredCustomers[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Name: ${customer.data['name'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Phone: ${customer.data['phone'] ?? 'N/A'}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Address: ${customer.data['address'] ?? 'N/A'}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              onPressed: () => _editCustomer(customer),
                                              icon: const Icon(Icons.edit, 
                                                  color: Colors.blue, size: 20),
                                            ),
                                            IconButton(
                                              onPressed: () => _deleteCustomer(customer.$id),
                                              icon: const Icon(Icons.delete, 
                                                  color: Colors.red, size: 20),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}