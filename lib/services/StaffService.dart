import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_client.dart'; // your file where Appwrite client & database are initialized

class StaffService {
  final String _databaseId = 'your-database-id'; // Replace with your DB ID
  final String _collectionId = 'staff'; // Replace with your collection ID

  // ✅ Add Staff
  Future<Document> addStaff({
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

  // ✅ Get All Staff
  Future<List<Document>> getAllStaff() async {
    final result = await databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
    );
    return result.documents;
  }

  // ✅ Update Staff by ID
  Future<Document> updateStaff({
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

  // ✅ Delete Staff by ID
  Future<void> deleteStaff(String documentId) async {
    await databases.deleteDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: documentId,
    );
  }

  // ✅ Search Staff by Name (partial match)
  Future<List<Document>> searchStaffByName(String nameQuery) async {
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
