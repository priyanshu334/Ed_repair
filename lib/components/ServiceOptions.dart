import 'package:ed_repair/pages/ManageEnginner.dart';
import 'package:ed_repair/services/ServiceCenterService.dart';
import 'package:flutter/material.dart';

// Data models to structure the returned data
class EngineerBookingData {
  final String engineerId;
  final String engineerName;
  final DateTime date;
  final TimeOfDay time;

  EngineerBookingData({
    required this.engineerId,
    required this.engineerName,
    required this.date,
    required this.time,
  });
}

class ServiceCenterBookingData {
  final String centerId;
  final String centerName;
  final DateTime date;
  final TimeOfDay time;

  ServiceCenterBookingData({
    required this.centerId,
    required this.centerName,
    required this.date,
    required this.time,
  });
}

class ServiceOptions extends StatelessWidget {
  final EngineerService _engineerService = EngineerService();
  final ServiceCenterService _serviceCenterService = ServiceCenterService();
  
  // Changed callbacks to required and non-nullable
  final Function(EngineerBookingData) onEngineerBooked;
  final Function(ServiceCenterBookingData) onServiceCenterBooked;

  ServiceOptions({
    Key? key,
    required this.onEngineerBooked,
    required this.onServiceCenterBooked,
  }) : super(key: key);

  void _showEngineerDialog(BuildContext context) async {
    final engineers = await _engineerService.getAllEngineers();
    String? selectedEngineerId;
    String? selectedEngineerName;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Select Engineer Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedEngineerId,
                        hint: const Text("Select Engineer"),
                        onChanged: (value) {
                          setState(() {
                            selectedEngineerId = value;
                            selectedEngineerName = engineers.firstWhere(
                              (e) => e.$id == value).data['name'];
                          });
                        },
                        items: engineers.map((engineer) => DropdownMenuItem(
                          value: engineer.$id,
                          child: Text(engineer.data['name']),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            selectedDate == null
                                ? 'Select Date'
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            selectedTime == null
                                ? 'Select Time'
                                : selectedTime!.format(context),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('CONFIRM'),
                onPressed: () {
                  if (selectedEngineerId == null || selectedDate == null || selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select all fields')));
                    return;
                  }
                  
                  final bookingData = EngineerBookingData(
                    engineerId: selectedEngineerId!,
                    engineerName: selectedEngineerName!,
                    date: selectedDate!,
                    time: selectedTime!,
                  );
                  
                  onEngineerBooked(bookingData);
                  Navigator.pop(context);
                  _showSuccessDialog(context, 'Engineer booked successfully!');
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showServiceCenterDialog(BuildContext context) async {
    final serviceCenters = await _serviceCenterService.getAllServiceCenters();
    String? selectedCenterId;
    String? selectedCenterName;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Select Service Center Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCenterId,
                        hint: const Text("Select Service Center"),
                        onChanged: (value) {
                          setState(() {
                            selectedCenterId = value;
                            selectedCenterName = serviceCenters.firstWhere(
                              (e) => e.$id == value).data['name'];
                          });
                        },
                        items: serviceCenters.map((center) => DropdownMenuItem(
                          value: center.$id,
                          child: Text(center.data['name']),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            selectedDate == null
                                ? 'Select Date'
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            selectedTime == null
                                ? 'Select Time'
                                : selectedTime!.format(context),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('CONFIRM'),
                onPressed: () {
                  if (selectedCenterId == null || selectedDate == null || selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select all fields')));
                    return;
                  }
                  
                  final bookingData = ServiceCenterBookingData(
                    centerId: selectedCenterId!,
                    centerName: selectedCenterName!,
                    date: selectedDate!,
                    time: selectedTime!,
                  );
                  
                  onServiceCenterBooked(bookingData);
                  Navigator.pop(context);
                  _showSuccessDialog(context, 'Service center appointment booked successfully!');
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose Service Type',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildServiceOption(
                  context,
                  'Engineer',
                  Icons.engineering,
                  _showEngineerDialog,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildServiceOption(
                  context,
                  'Service Center',
                  Icons.store,
                  _showServiceCenterDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption(
    BuildContext context,
    String title,
    IconData icon,
    Function(BuildContext) onTap,
  ) {
    return InkWell(
      onTap: () => onTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}