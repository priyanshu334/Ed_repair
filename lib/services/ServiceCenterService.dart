import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_client.dart';

class ServiceCenterService {
  final String _databaseId = '682ee050001301b2b3e2'; // 🔁 Replace with your actual Appwrite database ID
  final String _collectionId = '683089510039318af50e'; // 🔁 Replace with your actual collection ID

  // ✅ Add Service Center
  Future<Document> addServiceCenter({
    required String name,
    required String number,
    required String address,
  }) async {
    return await databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: ID.unique(),
      data: {
        'name': name,
        'number': number,
        'address': address,
      },
    );
  }

  // ✅ Get All Service Centers
  Future<List<Document>> getAllServiceCenters() async {
    final result = await databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
    );
    return result.documents;
  }

  // ✅ Update Service Center by ID
  Future<Document> updateServiceCenter({
    required String documentId,
    String? name,
    String? number,
    String? address,
  }) async {
    final Map<String, dynamic> updatedData = {};
    if (name != null) updatedData['name'] = name;
    if (number != null) updatedData['number'] = number;
    if (address != null) updatedData['address'] = address;

    return await databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: documentId,
      data: updatedData,
    );
  }

  // ✅ Delete Service Center by ID
  Future<void> deleteServiceCenter(String documentId) async {
    await databases.deleteDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: documentId,
    );
  }

  // ✅ Search Service Centers by Name (case-insensitive, partial match)
  Future<List<Document>> searchServiceCentersByName(String nameQuery) async {
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
