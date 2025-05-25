import 'package:ed_repair/services/ServiceCenterService.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
 // Import your service class

class ServiceCenterScreen extends StatefulWidget {
  const ServiceCenterScreen({super.key});

  @override
  State<ServiceCenterScreen> createState() => _ServiceCenterScreenState();
}

class _ServiceCenterScreenState extends State<ServiceCenterScreen> {
  final ServiceCenterService _serviceCenterService = ServiceCenterService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Document> _serviceCenters = [];
  List<Document> _filteredServiceCenters = [];
  bool _isLoading = false;
  String? _editingDocumentId;

  @override
  void initState() {
    super.initState();
    _loadServiceCenters();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredServiceCenters = _serviceCenters;
      } else {
        _filteredServiceCenters = _serviceCenters.where((center) {
          String name = center.data['name'].toString().toLowerCase();
          String number = center.data['number'].toString().toLowerCase();
          String address = center.data['address'].toString().toLowerCase();
          return name.contains(query) || number.contains(query) || address.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadServiceCenters() async {
    setState(() => _isLoading = true);
    try {
      final centers = await _serviceCenterService.getAllServiceCenters();
      setState(() {
        _serviceCenters = centers;
        _filteredServiceCenters = centers;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load service centers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addOrUpdateServiceCenter() async {
    if (_nameController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      _showErrorSnackBar('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_editingDocumentId != null) {
        // Update existing service center
        await _serviceCenterService.updateServiceCenter(
          documentId: _editingDocumentId!,
          name: _nameController.text.trim(),
          number: _numberController.text.trim(),
          address: _addressController.text.trim(),
        );
        _showSuccessSnackBar('Service center updated successfully');
      } else {
        // Add new service center
        await _serviceCenterService.addServiceCenter(
          name: _nameController.text.trim(),
          number: _numberController.text.trim(),
          address: _addressController.text.trim(),
        );
        _showSuccessSnackBar('Service center added successfully');
      }
      
      _clearForm();
      await _loadServiceCenters();
    } catch (e) {
      _showErrorSnackBar('Operation failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteServiceCenter(String documentId) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await _serviceCenterService.deleteServiceCenter(documentId);
      _showSuccessSnackBar('Service center deleted successfully');
      await _loadServiceCenters();
    } catch (e) {
      _showErrorSnackBar('Failed to delete service center: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _editServiceCenter(Document document) {
    setState(() {
      _editingDocumentId = document.$id;
      _nameController.text = document.data['name'] ?? '';
      _numberController.text = document.data['number'] ?? '';
      _addressController.text = document.data['address'] ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingDocumentId = null;
      _nameController.clear();
      _numberController.clear();
      _addressController.clear();
    });
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this service center?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2538),
      appBar: AppBar(
        title: const Text(
          'Service Center',
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
                          'Manage Service Centers',
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
                                  hintText: 'Search Service Centers',
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
                        'Service Center Name',
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
                        'Service Center Number',
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
                          controller: _numberController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Service Center Address',
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
                          if (_editingDocumentId != null) ...[
                            Container(
                              height: 36,
                              width: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TextButton(
                                onPressed: _clearForm,
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
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
                            child: TextButton(
                              onPressed: _isLoading ? null : _addOrUpdateServiceCenter,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(
                                      _editingDocumentId != null ? 'Update' : 'Add',
                                      style: const TextStyle(
                                        color: Color(0xFF1A2538),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
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
            
            // Service Centers List
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
              ),
              child: _isLoading && _serviceCenters.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _filteredServiceCenters.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No service centers found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredServiceCenters.length,
                          itemBuilder: (context, index) {
                            final center = _filteredServiceCenters[index];
                            final data = center.data;
                            
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Name: ${data['name'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () => _editServiceCenter(center),
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => _deleteServiceCenter(center.$id),
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Number: ${data['number'] ?? 'N/A'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Address: ${data['address'] ?? 'N/A'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
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
    );
  }
}