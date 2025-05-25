import 'package:appwrite/models.dart';
import 'package:ed_repair/components/OrderCard.dart';
import 'package:ed_repair/components/OrdersFilter.dart';
import 'package:ed_repair/components/OrdersList.dart';
import 'package:ed_repair/pages/EditOrders.dart';
import 'package:ed_repair/pages/ViewPage.dart';
import 'package:ed_repair/services/OrderService.dart';
import 'package:flutter/material.dart';
import 'package:ed_repair/pages/AddOrders.dart';


class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  Map<String, dynamic> _currentFilters = {};
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final documents = await _orderService.getAllOrders();
      final orders = documents.map((doc) => _documentToOrderModel(doc)).toList();
      print('Fetched ${orders.length} orders');
      
      setState(() {
        _allOrders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch orders: ${e.toString()}')),
      );
    }
  }

  OrderModel _documentToOrderModel(Document doc) {
    final data = doc.data;
    return OrderModel(
      id: doc.$id,
      customerName: data['customer']['name'] ?? 'Unknown Customer',
      status: data['status'] ?? 'Unknown',
      dueDate: _formatDateString(data['estimate']['date']),
      serviceProvider: data['engineer']['engineer'] ?? 'Unknown Engineer',
      serviceCenter: data['serviceCenter']['serviceCenter'] ?? 'Unknown Center',
      // Add other fields as needed
    );
  }

  String _formatDateString(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
    } catch (e) {
      return 'N/A';
    }
  }

/*************  ✨ Windsurf Command ⭐  *************/
  /// Updates the current filter criteria and triggers a loading state. 
  /// After a short delay to simulate an API call, applies the filters 
  /// to the list of all orders and updates the filtered orders list.
  /// 
  /// The loading state is reset once the filtering is complete.
  ///
  /// [filters] A map containing the filter criteria to be applied.

/*******  b493b59b-27a4-4bad-b802-98686cf2e61a  *******/  void _handleFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
      _isLoading = true;
    });

    // Simulate API call delay (remove in production)
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _filteredOrders = _applyFilters(_allOrders, filters);
        _isLoading = false;
      });
    });
  }

  List<OrderModel> _applyFilters(List<OrderModel> orders, Map<String, dynamic> filters) {
    if (filters.isEmpty) return orders;

    return orders.where((order) {
      // Status filter
      if (filters['status'] != null && filters['status'].isNotEmpty) {
        if (order.status.toLowerCase() != filters['status'].toLowerCase()) {
          return false;
        }
      }

      // Customer name filter
      if (filters['customerName'] != null && filters['customerName'].isNotEmpty) {
        if (!order.customerName.toLowerCase().contains(filters['customerName'].toLowerCase())) {
          return false;
        }
      }

      // Due date filter
      if (filters['dueDate'] != null) {
        if (order.dueDate != _formatDate(filters['dueDate'])) {
          return false;
        }
      }

      // Service provider filter
      if (filters['serviceProvider'] != null && filters['serviceProvider'].isNotEmpty) {
        if (order.serviceProvider == null || 
            !order.serviceProvider!.toLowerCase().contains(filters['serviceProvider'].toLowerCase())) {
          return false;
        }
      }

      // Service center filter
      if (filters['serviceCenter'] != null && filters['serviceCenter'].isNotEmpty) {
        if (order.serviceCenter == null || 
            !order.serviceCenter!.toLowerCase().contains(filters['serviceCenter'].toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
  }

  Future<void> _viewOrder(String orderId) async {
    try {
      final orderDoc = await _orderService.getOrderById(orderId);
      final order = _documentToOrderModel(orderDoc);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewPage(orderId: order.id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order details: ${e.toString()}')),
      );
    }
  }

  Future<void> _editOrder(String orderId) async {
    try {
      final orderDoc = await _orderService.getOrderById(orderId);
      final order = _documentToOrderModel(orderDoc);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditOrderPage(orderId: order.id),
        ),
      ).then((updatedOrder) {
        if (updatedOrder != null && updatedOrder is OrderModel) {
          _fetchOrders(); // Refresh the list after editing
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order for editing: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _orderService.deleteOrder(orderId);
      
      setState(() {
        _allOrders.removeWhere((order) => order.id == orderId);
        _filteredOrders = _applyFilters(_allOrders, _currentFilters);
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order deleted successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete order: ${e.toString()}')),
      );
    }
  }

  void _addNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddOrdersPage()),
    ).then((value) {
      if (value != null && value is bool && value) {
        _fetchOrders(); // Refresh the list after adding
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewOrder,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OrdersFilter(
              onFiltersChanged: _handleFiltersChanged,
              initialFilters: _currentFilters,
            ),
            const SizedBox(height: 16),
            if (_hasError)
              Column(
                children: [
                  const Text('Failed to load orders'),
                  ElevatedButton(
                    onPressed: _fetchOrders,
                    child: const Text('Retry'),
                  ),
                ],
              )
            else
              OrdersList(
                orders: _filteredOrders,
                onViewOrder: _viewOrder,
                onEditOrder: _editOrder,
                onDeleteOrder: _deleteOrder,
                isLoading: _isLoading,
                emptyMessage: _currentFilters.isEmpty 
                    ? 'No orders available' 
                    : 'No orders match your filters',
              ),
          ],
        ),
      ),
    );
  }
}