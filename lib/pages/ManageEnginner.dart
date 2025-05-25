import 'package:ed_repair/services/appwrite_client.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
// Ensure this exports `databases`

class EngineerService {
  final String _databaseId = '682ee050001301b2b3e2';
  final String _collectionId = '683088f70031bf5c85c5';

  // ✅ Add Engineer
  Future<Document> addEngineer({
    required String name,
    required String phone,
    required String address,
  }) async {
    return await databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: ID.unique(),
      data: {
        'name': name,
        'phone': phone,
        'address': address,
      },
    );
  }

  // ✅ Get All Engineers
  Future<List<Document>> getAllEngineers() async {
    final result = await databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
    );
    return result.documents;
  }

  // ✅ Update Engineer
  Future<Document> updateEngineer({
    required String documentId,
    String? name,
    String? phone,
    String? address,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;

    return await databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: documentId,
      data: data,
    );
  }

  // ✅ Delete Engineer
  Future<void> deleteEngineer(String documentId) async {
    await databases.deleteDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: documentId,
    );
  }

  // ✅ Search Engineers by name
  Future<List<Document>> searchEngineersByName(String nameQuery) async {
    final result = await databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
      queries: [
        Query.search('name', nameQuery),
      ],
    );
    return result.documents;
  }
}

class EngineerScreen extends StatefulWidget {
  const EngineerScreen({super.key});

  @override
  State<EngineerScreen> createState() => _EngineerScreenState();
}

class _EngineerScreenState extends State<EngineerScreen> {
  final EngineerService _engineerService = EngineerService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Document> _engineers = [];
  List<Document> _filteredEngineers = [];
  bool _isLoading = false;
  String? _editingDocumentId;

  @override
  void initState() {
    super.initState();
    _loadEngineers();
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
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEngineers = _engineers;
      } else {
        _filteredEngineers = _engineers.where((engineer) {
          String name = engineer.data['name'].toString().toLowerCase();
          String phone = engineer.data['phone'].toString().toLowerCase();
          String address = engineer.data['address'].toString().toLowerCase();
          return name.contains(query) || phone.contains(query) || address.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadEngineers() async {
    setState(() => _isLoading = true);
    try {
      final engineers = await _engineerService.getAllEngineers();
      setState(() {
        _engineers = engineers;
        _filteredEngineers = engineers;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load engineers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addOrUpdateEngineer() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      _showErrorSnackBar('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_editingDocumentId != null) {
        // Update existing engineer
        await _engineerService.updateEngineer(
          documentId: _editingDocumentId!,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );
        _showSuccessSnackBar('Engineer updated successfully');
      } else {
        // Add new engineer
        await _engineerService.addEngineer(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );
        _showSuccessSnackBar('Engineer added successfully');
      }
      
      _clearForm();
      await _loadEngineers();
    } catch (e) {
      _showErrorSnackBar('Operation failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEngineer(String documentId) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await _engineerService.deleteEngineer(documentId);
      _showSuccessSnackBar('Engineer deleted successfully');
      await _loadEngineers();
    } catch (e) {
      _showErrorSnackBar('Failed to delete engineer: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _editEngineer(Document document) {
    setState(() {
      _editingDocumentId = document.$id;
      _nameController.text = document.data['name'] ?? '';
      _phoneController.text = document.data['phone'] ?? '';
      _addressController.text = document.data['address'] ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingDocumentId = null;
      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();
    });
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this engineer?'),
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
          'Manage Engineer',
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
                          'Manage Engineers',
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
                                  hintText: 'Search Engineers',
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
                        'Engineer Name',
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
                        'Engineer Number',
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
                        'Engineer Address',
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
                              onPressed: _isLoading ? null : _addOrUpdateEngineer,
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
            
            // Engineers List
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
              ),
              child: _isLoading && _engineers.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _filteredEngineers.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No engineers found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredEngineers.length,
                          itemBuilder: (context, index) {
                            final engineer = _filteredEngineers[index];
                            final data = engineer.data;
                            
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
                                            onPressed: () => _editEngineer(engineer),
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
                                            onPressed: () => _deleteEngineer(engineer.$id),
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
                                    'Number: ${data['phone'] ?? 'N/A'}',
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