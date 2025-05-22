import 'package:flutter/material.dart';

// Model class for Customer
class Customer {
  final String id;
  final String name;
  final String email;

  Customer({required this.id, required this.name, required this.email});
}

class SelectCustomerBox extends StatefulWidget {
  final Function(Customer)? onCustomerSelected;

  const SelectCustomerBox({super.key, this.onCustomerSelected});

  @override
  State<SelectCustomerBox> createState() => _SelectCustomerBoxState();
}

class _SelectCustomerBoxState extends State<SelectCustomerBox> {
  // Sample customer data - replace with your actual data source
  final List<Customer> _allCustomers = [
    Customer(id: '1', name: 'John Doe', email: 'john@example.com'),
    Customer(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
    Customer(id: '3', name: 'Robert Johnson', email: 'robert@example.com'),
    Customer(id: '4', name: 'Emily Davis', email: 'emily@example.com'),
    Customer(id: '5', name: 'Michael Wilson', email: 'michael@example.com'),
  ];

  Customer? _selectedCustomer;

  void _showCustomerSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomerSelectionDialog(
        customers: _allCustomers,
        onSelectCustomer: (customer) {
          setState(() {
            _selectedCustomer = customer;
          });
          if (widget.onCustomerSelected != null) {
            widget.onCustomerSelected!(customer);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF232524), // dark background
      child: Center(
        child: InkWell(
          onTap: _showCustomerSelectionDialog,
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
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  _selectedCustomer?.name ?? 'Select Customer',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerSelectionDialog extends StatefulWidget {
  final List<Customer> customers;
  final Function(Customer) onSelectCustomer;

  const CustomerSelectionDialog({
    super.key,
    required this.customers,
    required this.onSelectCustomer,
  });

  @override
  State<CustomerSelectionDialog> createState() => _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends State<CustomerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCustomers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = widget.customers.where((customer) {
        return customer.name.toLowerCase().contains(query) ||
            customer.email.toLowerCase().contains(query);
      }).toList();
    });
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
            const Text(
              'Select Customer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
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
            // Customer List
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: _filteredCustomers.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No customers found'),
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
            // Done Button
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
      subtitle: Text(customer.email),
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