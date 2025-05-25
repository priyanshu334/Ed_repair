import 'package:ed_repair/components/DeviceKycForm.dart';
import 'package:ed_repair/components/EnginnerCompo.dart';
import 'package:ed_repair/components/EstimateDetailsFom.dart';
import 'package:ed_repair/components/OrderDetailsForm.dart';
import 'package:ed_repair/components/PickupForm.dart';
import 'package:ed_repair/components/ServiceCenterCompo.dart';
import 'package:ed_repair/components/ServiceOptions.dart';
import 'package:ed_repair/components/selectCustomerBox.dart';
import 'package:ed_repair/services/OrderService.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class EditOrderPage extends StatefulWidget {
  final String orderId;

  const EditOrderPage({super.key, required this.orderId});

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _hasChanges = false;
  
  Map<String, dynamic> _estimateDetails = {};
  Map<String, dynamic> _deviceDetails = {};
  Map<String, dynamic> _orderDetails = {
    'status': 'pending',
    'notes': '',
  };
  Map<String, dynamic> _customerDetails = {};
  Map<String, dynamic> engineerSelectionData = {};
  Map<String, dynamic> serviceCenterSelectionData = {};

  final OrderService _orderService = OrderService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    try {
      final order = await _orderService.getOrderById(widget.orderId);
      
      if (mounted) {
        setState(() {
          _customerDetails = Map<String, dynamic>.from(order.data['customer'] ?? {});
          _estimateDetails = Map<String, dynamic>.from(order.data['estimate'] ?? {});
          _deviceDetails = Map<String, dynamic>.from(order.data['device'] ?? {});
          _orderDetails = Map<String, dynamic>.from(order.data['orderDetails'] ?? {
            'status': order.data['status'] ?? 'pending',
            'notes': '',
          });
          engineerSelectionData = Map<String, dynamic>.from(order.data['engineer'] ?? {});
          serviceCenterSelectionData = Map<String, dynamic>.from(order.data['serviceCenter'] ?? {});
          _agreedToTerms = true; // Assuming they agreed when creating
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load order: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Don't automatically pop - let user decide
        _showErrorDialog('Error Loading Order', 
          'Could not load order data. Please check your connection and try again.\n\nError: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadOrderData(); // Retry loading
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Helper function to convert DateTime objects to strings recursively
  Map<String, dynamic> _sanitizeDataForJson(Map<String, dynamic> data) {
    Map<String, dynamic> sanitized = {};
    
    data.forEach((key, value) {
      if (value is DateTime) {
        sanitized[key] = value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeDataForJson(value);
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is DateTime) {
            return item.toIso8601String();
          } else if (item is Map<String, dynamic>) {
            return _sanitizeDataForJson(item);
          }
          return item;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    });
    
    return sanitized;
  }

  bool _validateForm() {
    List<String> errors = [];

    if (_customerDetails.isEmpty) {
      errors.add('Customer information is required');
    }

    if (_estimateDetails.isEmpty) {
      errors.add('Estimate details are required');
    }

    if (_deviceDetails.isEmpty) {
      errors.add('Device information is required');
    }

    if (engineerSelectionData.isEmpty) {
      errors.add('Engineer selection is required');
    }

    if (serviceCenterSelectionData.isEmpty) {
      errors.add('Service center selection is required');
    }

    if (!_agreedToTerms) {
      errors.add('Please agree to the terms and conditions');
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please fix the following issues:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...errors.map((error) => Text('• $error')),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _updateOrder() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Sanitize all data to ensure DateTime objects are converted to strings
      final sanitizedCustomer = _sanitizeDataForJson(_customerDetails);
      final sanitizedEstimate = _sanitizeDataForJson(_estimateDetails);
      final sanitizedDevice = _sanitizeDataForJson(_deviceDetails);
      final sanitizedOrderDetails = _sanitizeDataForJson(_orderDetails);
      final sanitizedEngineer = _sanitizeDataForJson(engineerSelectionData);
      final sanitizedServiceCenter = _sanitizeDataForJson(serviceCenterSelectionData);

      // Call the OrderService to update the order
      await _orderService.updateFullOrder(
        orderId: widget.orderId,
        customers: sanitizedCustomer,
        estimate: sanitizedEstimate,
        device: sanitizedDevice,
        orderDetails: sanitizedOrderDetails,
        engineer: sanitizedEngineer,
        serviceCenter: sanitizedServiceCenter,
        status: _orderDetails['status'],
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Order updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          _hasChanges = false;
        });

        // Navigate back
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Failed to update order', 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(e.toString()),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            _hasChanges ? 'Edit Order*' : 'Edit Order',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadOrderData,
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
              tooltip: 'Delete Order',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading order data...'),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Order',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Order ID: ${widget.orderId}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        if (_hasChanges)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'You have unsaved changes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 25),
                        
                        // Form Sections
                        _buildFormSection(
                          'Customer Information*',
                          SelectCustomerBox(
                            initialCustomer: _customerDetails,
                            onCustomerChanged: (Map<String, dynamic>? customer) {
                              setState(() {
                                _customerDetails = customer ?? {};
                              });
                              _markAsChanged();
                            },
                          ),
                        ),
                        
                        _buildFormSection(
                          'Estimate Details*',
                          EstimateDetailsForm(
                            initialData: _estimateDetails,
                            onFormChanged: (Map<String, dynamic> estimateData) {
                              setState(() {
                                _estimateDetails = estimateData;
                              });
                              _markAsChanged();
                            },
                          ),
                        ),
                        
                        _buildFormSection(
                          'Device Information*',
                          DeviceKycForm(
                            initialData: _deviceDetails,
                            onFormChanged: (Map<String, dynamic> deviceData) {
                              setState(() {
                                _deviceDetails = deviceData;
                              });
                              _markAsChanged();
                            },
                          ),
                        ),
                        
                        _buildFormSection(
                          'Order Details',
                          OrderDetailsForm(
                            initialData: _orderDetails,
                            onOrderChanged: (Map<String, dynamic> orderData) {
                              setState(() {
                                _orderDetails = orderData;
                              });
                              _markAsChanged();
                            },
                          ),
                        ),

                        _buildFormSection(
                          "Select Engineer*", 
                          EngineerSelectorPage(
                            initialSelection: engineerSelectionData,
                            onSelectionChanged: (Map<String, dynamic>? engineerData) {
                              setState(() {
                                engineerSelectionData = engineerData ?? {};
                              });
                              _markAsChanged();
                            },
                          ),
                        ),
                        
                        _buildFormSection(
                          "Select Service Center*", 
                          ServiceCenterSelectorPage(
                            initialSelection: serviceCenterSelectionData,
                            onSelectionChanged: (Map<String, dynamic>? serviceCenterData) {
                              setState(() {
                                serviceCenterSelectionData = serviceCenterData ?? {};
                              });
                              _markAsChanged();
                            },
                          ),
                        ),
                        
                        // Terms and Conditions
                        Container(
                          margin: const EdgeInsets.only(top: 30, bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreedToTerms,
                                    activeColor: Colors.blue,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _agreedToTerms = value ?? false;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _agreedToTerms = !_agreedToTerms;
                                        });
                                      },
                                      child: const Text(
                                        'I agree to the Terms and Conditions and Privacy Policy',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Update Button
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 10),
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _updateOrder,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 56, 109, 40),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    disabledBackgroundColor: Colors.grey.shade300,
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Update Order',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFormSection(String title, Widget formWidget) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (title.endsWith('*'))
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: formWidget,
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await _orderService.deleteOrder(widget.orderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Order deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, 'deleted'); // Return 'deleted' to indicate deletion
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete order: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}