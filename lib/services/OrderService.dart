import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_client.dart';

class OrderService {
  final String _databaseId = '682ee050001301b2b3e2';
  final String _collectionId = '683224130010d37c9ddb';

  // ✅ Create a new order
  Future<Document> createOrder({
    required Map<String, dynamic> customers,
    required Map<String, dynamic> estimate,
    required Map<String, dynamic> device,
    required Map<String, dynamic> orderDetails,
    required Map<String, dynamic> engineer,
    required Map<String, dynamic> serviceCenter,
  }) async {
    return await databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: ID.unique(),
      data: {
        'customer': customers,
        'estimate': estimate,
        'device': device,
        'orderDetails': orderDetails,
        'engineer': engineer,
        'serviceCenter': serviceCenter,
        'status': 'created',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  // ✅ Get all orders (with pagination)
  Future<List<Document>> getAllOrders({
    int limit = 100,
    int offset = 0,
    String orderField = 'createdAt',
    String orderType = 'DESC',
  }) async {
    final result = await databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
      queries: [
        Query.limit(limit),
        Query.offset(offset),
        Query.orderDesc(orderField),
      ],
    );
    return result.documents;
  }

  // ✅ Get order by ID
  Future<Document> getOrderById(String orderId) async {
    return await databases.getDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: orderId,
    );
  }

  // ✅ Delete order by ID
  Future<void> deleteOrder(String orderId) async {
    await databases.deleteDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: orderId,
    );
  }

  // ✅ Delete multiple orders by IDs
  Future<void> deleteMultipleOrders(List<String> orderIds) async {
    await Future.wait(
      orderIds.map((id) => deleteOrder(id)),
    );
  }

  // ✅ Soft delete order (mark as deleted instead of actual deletion)
  Future<Document> softDeleteOrder(String orderId) async {
    return await databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: orderId,
      data: {
        'isDeleted': true,
        'deletedAt': DateTime.now().toIso8601String(),
        'status': 'deleted',
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  // ✅ Restore soft-deleted order
  Future<Document> restoreOrder(String orderId) async {
    return await databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: orderId,
      data: {
        'isDeleted': false,
        'deletedAt': null,
        'status': 'restored',
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  // ✅ Update entire order - FIXED the typo here
  Future<Document> updateFullOrder({
    required String orderId,
    Map<String, dynamic>? customers,
    Map<String, dynamic>? estimate,
    Map<String, dynamic>? device,
    Map<String, dynamic>? orderDetails,
    Map<String, dynamic>? engineer,
    Map<String, dynamic>? serviceCenter,
    String? status,
  }) async {
    final currentOrder = await getOrderById(orderId);
    
    return await databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: orderId,
      data: {
        'customer': customers ?? currentOrder.data['customer'], // Fixed: was 'customers'
        'estimate': estimate ?? currentOrder.data['estimate'],
        'device': device ?? currentOrder.data['device'],
        'orderDetails': orderDetails ?? currentOrder.data['orderDetails'],
        'engineer': engineer ?? currentOrder.data['engineer'],
        'serviceCenter': serviceCenter ?? currentOrder.data['serviceCenter'],
        'status': status ?? currentOrder.data['status'],
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  // ✅ Update specific order components
  Future<Document> updateOrderCustomer(String orderId, Map<String, dynamic> customer) async {
    return await _updateOrderComponent(orderId, 'customer', customer);
  }

  Future<Document> updateOrderEstimate(String orderId, Map<String, dynamic> estimate) async {
    return await _updateOrderComponent(orderId, 'estimate', estimate);
  }

  Future<Document> updateOrderDevice(String orderId, Map<String, dynamic> device) async {
    return await _updateOrderComponent(orderId, 'device', device);
  }

  Future<Document> updateOrderDetails(String orderId, Map<String, dynamic> orderDetails) async {
    return await _updateOrderComponent(orderId, 'orderDetails', orderDetails);
  }

  Future<Document> updateOrderEngineer(String orderId, Map<String, dynamic> engineer) async {
    return await _updateOrderComponent(orderId, 'engineer', engineer);
  }

  Future<Document> updateOrderServiceCenter(String orderId, Map<String, dynamic> serviceCenter) async {
    return await _updateOrderComponent(orderId, 'serviceCenter', serviceCenter);
  }

  // Helper method for component updates
  Future<Document> _updateOrderComponent(
    String orderId, 
    String componentName, 
    Map<String, dynamic> componentData
  ) async {
    return await databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: orderId,
      data: {
        componentName: componentData,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  // ✅ Get deleted orders
  Future<List<Document>> getDeletedOrders() async {
    final result = await databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
      queries: [
        Query.equal('isDeleted', true),
      ],
    );
    return result.documents;
  }

  // ✅ Permanent delete all soft-deleted orders
  Future<void> purgeDeletedOrders() async {
    final deletedOrders = await getDeletedOrders();
    await deleteMultipleOrders(
      deletedOrders.map((doc) => doc.$id).toList(),
    );
  }

  // ✅ Additional helper methods for better error handling
  Future<bool> orderExists(String orderId) async {
    try {
      await getOrderById(orderId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ✅ Get orders by status
  Future<List<Document>> getOrdersByStatus(String status) async {
    final result = await databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
      queries: [
        Query.equal('status', status),
        Query.orderDesc('createdAt'),
      ],
    );
    return result.documents;
  }

  // ✅ Search orders by customer name or phone
  Future<List<Document>> searchOrders(String searchTerm) async {
    final result = await databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
      queries: [
        Query.search('customer.name', searchTerm),
        Query.orderDesc('createdAt'),
      ],
    );
    return result.documents;
  }

  // ✅ Update order status only
  Future<Document> updateOrderStatus(String orderId, String status) async {
    return await databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: orderId,
      data: {
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}