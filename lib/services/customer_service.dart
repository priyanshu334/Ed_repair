import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_client.dart';

class CustomerService {
  final String _databaseId = '682ee050001301b2b3e2';
  final String _collectionId = '6832caed002f5778ed18';

  // ✅ Add Customer
  Future<Document> addCustomer({
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

  // ✅ Get All Customers
  Future<List<Document>> getAllCustomers() async {
    final result = await databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
    );
    return result.documents;
  }

  // ✅ Update Customer by ID
  Future<Document> updateCustomer({
    required String documentId,
    String? name,
    String? phone,
    String? address,
  }) async {
    final Map<String, dynamic> updatedData = {};
    if (name != null) updatedData['name'] = name;
    if (phone != null) updatedData['phone'] = phone;
    if (address != null) updatedData['address'] = address;

    return await databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: documentId,
      data: updatedData,
    );
  }

  // ✅ Delete Customer by ID
  Future<void> deleteCustomer(String documentId) async {
    await databases.deleteDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: documentId,
    );
  }

  // ✅ Search Customers by Name (partial match, case-insensitive)
  Future<List<Document>> searchCustomersByName(String nameQuery) async {
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
