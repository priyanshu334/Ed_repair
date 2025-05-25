import 'package:ed_repair/services/ServiceCenterService.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';

class ServiceCenterSelectorPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelectionChanged;

  const ServiceCenterSelectorPage({
    super.key,
    required this.onSelectionChanged,
  });

  @override
  State<ServiceCenterSelectorPage> createState() => _ServiceCenterSelectorPageState();
}

class _ServiceCenterSelectorPageState extends State<ServiceCenterSelectorPage> {
  String? selectedCenter;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<String> serviceCenters = [];
  bool isLoading = true;

  final ServiceCenterService _serviceCenterService = ServiceCenterService();

  @override
  void initState() {
    super.initState();
    _fetchServiceCenters();
  }

  Future<void> _fetchServiceCenters() async {
    try {
      final List<Document> centerDocs = await _serviceCenterService.getAllServiceCenters();
      setState(() {
        serviceCenters = centerDocs.map((doc) => doc.data['name'] as String).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load service centers: $e')),
      );
    }
  }

  void _openDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.business,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Select Service Center',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonFormField<String>(
                              value: selectedCenter,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.location_on),
                                hintText: 'Choose Service Center',
                              ),
                              items: serviceCenters
                                  .map((center) => DropdownMenuItem(
                                        value: center,
                                        child: Text(center),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedCenter = value;
                                });
                                setState(() {
                                  selectedCenter = value;
                                  _notifyParent();
                                });
                              },
                            ),
                          ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          selectedDate == null
                              ? 'Select Date'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style: TextStyle(
                            color: selectedDate == null 
                                ? Colors.grey.shade600 
                                : Colors.black87,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                            setState(() {
                              selectedDate = picked;
                              _notifyParent();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.access_time,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          selectedTime == null
                              ? 'Select Time'
                              : selectedTime!.format(context),
                          style: TextStyle(
                            color: selectedTime == null 
                                ? Colors.grey.shade600 
                                : Colors.black87,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedTime = picked;
                            });
                            setState(() {
                              selectedTime = picked;
                              _notifyParent();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _notifyParent();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _notifyParent() {
    final selectionData = {
      'serviceCenter': selectedCenter,
      'date': selectedDate?.toIso8601String(),
      'time': selectedTime?.format(context),
      'isComplete': selectedCenter != null && selectedDate != null && selectedTime != null,
    };
    
    widget.onSelectionChanged(selectionData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedCenter != null || selectedDate != null || selectedTime != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedCenter != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.business, 
                                size: 20, 
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              selectedCenter!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, 
                                size: 20, 
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (selectedTime != null)
                      Row(
                        children: [
                          Icon(Icons.access_time, 
                              size: 20, 
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            selectedTime!.format(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          IconButton(
            onPressed: _openDialog,
            icon: const Icon(Icons.business),
            iconSize: 32,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}