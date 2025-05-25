import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_client.dart'; // Ensure this exports `databases`

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
