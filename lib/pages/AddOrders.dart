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

class AddOrdersPage extends StatefulWidget {
  const AddOrdersPage({super.key});

  @override
  State<AddOrdersPage> createState() => _AddOrdersPageState();
}

class _AddOrdersPageState extends State<AddOrdersPage> {
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  Map<String, dynamic> _estimateDetails = {};
  Map<String, dynamic> _deviceDetails = {};
  Map<String, dynamic> _orderDetails = {
    'status': 'pending', // Default status
    'notes': '',
  };
  Map<String, dynamic> _customerDetails = {};
  Map<String, dynamic> engineerSelectionData = {};
  Map<String, dynamic> serviceCenterSelectionData = {};

  final OrderService _orderService = OrderService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  Future<void> _submitOrder() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate all forms
    if (_customerDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_estimateDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill estimate details'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_deviceDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill device details'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (engineerSelectionData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an engineer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (serviceCenterSelectionData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service center'),
          backgroundColor: Colors.orange,
        ),
      );
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

      // Call the OrderService to create the order
      final result = await _orderService.createOrder(
        customers: sanitizedCustomer,
        estimate: sanitizedEstimate,
        device: sanitizedDevice,
        orderDetails: sanitizedOrderDetails,
        engineer: sanitizedEngineer,
        serviceCenter: sanitizedServiceCenter,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Reset the form and navigate back
        _resetForm();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit order: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

  void _resetForm() {
    setState(() {
      _estimateDetails = {};
      _deviceDetails = {};
      _orderDetails = {
        'status': 'pending',
        'notes': '',
      };
      _customerDetails = {};
      engineerSelectionData = {};
      serviceCenterSelectionData = {};
      _agreedToTerms = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Order',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Please fill in all the required information',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 25),
                
                // Form Sections
                _buildFormSection(
                  'Customer Information*',
                  SelectCustomerBox(
                    onCustomerChanged: (Map<String, dynamic>? customer) {
                      setState(() {
                        _customerDetails = customer ?? {};
                      });
                    },
                  ),
                ),
                
                _buildFormSection(
                  'Estimate Details*',
                  EstimateDetailsForm(
                    onFormChanged: (Map<String, dynamic> estimateData) {
                      setState(() {
                        _estimateDetails = estimateData;
                      });
                    },
                  ),
                ),
                
                _buildFormSection(
                  'Device Information*',
                  DeviceKycForm(
                    onFormChanged: (Map<String, dynamic> deviceData) {
                      setState(() {
                        _deviceDetails = deviceData;
                      });
                    },
                  ),
                ),
                
                _buildFormSection(
                  'Order Details',
                  OrderDetailsForm(
                    onOrderChanged: (Map<String, dynamic> orderData) {
                      setState(() {
                        _orderDetails = orderData;
                      });
                    },
                  ),
                ),

                _buildFormSection(
                  "Select Engineer*", 
                  EngineerSelectorPage(
                    onSelectionChanged: (Map<String, dynamic>? engineerData) {
                      setState(() {
                        engineerSelectionData = engineerData ?? {};
                      });
                    },
                  ),
                ),
                
                _buildFormSection(
                  "Select Service Center*", 
                  ServiceCenterSelectorPage(
                    onSelectionChanged: (Map<String, dynamic>? serviceCenterData) {
                      setState(() {
                        serviceCenterSelectionData = serviceCenterData ?? {};
                      });
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
                      
                      // Submit Button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitOrder,
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
                                  'Submit Order',
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
}