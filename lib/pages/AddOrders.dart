import 'package:ed_repair/components/DeviceKycForm.dart';
import 'package:ed_repair/components/EstimateDetailsFom.dart';
import 'package:ed_repair/components/OrderDetailsForm.dart';
import 'package:ed_repair/components/PickupForm.dart';
import 'package:ed_repair/components/ServiceOptions.dart';
import 'package:ed_repair/components/selectCustomerBox.dart';
import 'package:ed_repair/pages/ServiceOptionsPage.dart';
import 'package:flutter/material.dart';

class AddOrdersPage extends StatefulWidget {
  const AddOrdersPage({super.key});

  @override
  State<AddOrdersPage> createState() => _AddOrdersPageState();
}

class _AddOrdersPageState extends State<AddOrdersPage> {
  bool _agreedToTerms = false;

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
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
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
                'Customer Information',
                const SelectCustomerBox(),
              ),
              
              _buildFormSection(
                'Estimate Details',
                const EstimateDetailsForm(),
              ),
              
              _buildFormSection(
                'Device Information',
                const DeviceKycForm(),
              ),
              
              _buildFormSection(
                'Order Details',
                const OrderDetailsForm(),
              ),
              
            
                 ServiceOptions(),

            

              
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
                        onPressed: _agreedToTerms 
                            ? () {
                                // Submit logic here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order submitted successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } 
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text(
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
          // Section header
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
              ],
            ),
          ),
          
          // Form content
          Padding(
            padding: const EdgeInsets.all(16),
            child: formWidget,
          ),
        ],
      ),
    );
  }
}