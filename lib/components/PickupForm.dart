import 'package:flutter/material.dart';

class PickupDetailsForm extends StatefulWidget {
  const PickupDetailsForm({super.key});

  @override
  State<PickupDetailsForm> createState() => _PickupDetailsFormState();
}

class _PickupDetailsFormState extends State<PickupDetailsForm> {
  bool isServiceProvider = true;

  String? selectedServiceProvider;
  String? selectedServiceCenter;
  DateTime? pickupDate;
  TimeOfDay? pickupTime;

  final List<String> serviceProviders = ['Provider A', 'Provider B'];
  final List<String> serviceCenters = ['Center 1', 'Center 2'];

  void _showServiceCenterDialog() {
    String? tempCenter;
    DateTime? tempDate;
    TimeOfDay? tempTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232524),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Select Pickup Details', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: 260,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: tempCenter,
                      items: serviceCenters.map((center) {
                        return DropdownMenuItem(value: center, child: Text(center));
                      }).toList(),
                      decoration: const InputDecoration(
                        hintText: 'Select Service Center',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => setState(() => tempCenter = value),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => tempDate = date);
                      },
                      child: Text(tempDate == null
                          ? 'Select Pickup Date'
                          : 'Pickup: ${tempDate!.toLocal().toString().split(' ')[0]}'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) setState(() => tempTime = time);
                      },
                      child: Text(tempTime == null
                          ? 'Select Pickup Time'
                          : 'Pickup: ${tempTime!.format(context)}'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedServiceCenter = tempCenter;
                          pickupDate = tempDate;
                          pickupTime = tempTime;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInputBox(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF232524),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toggleButton('Service Provider', true),
              const SizedBox(width: 8),
              _toggleButton('Service Center', false),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          if (isServiceProvider) ...[
            _buildInputBox('select Service provider'),
            _buildInputBox('Select pickup date'),
            _buildInputBox('Select pickup time'),
          ] else ...[
            GestureDetector(
              onTap: _showServiceCenterDialog,
              child: _buildInputBox(
                  selectedServiceCenter ?? 'Select Service Center'),
            ),
            _buildInputBox(pickupDate == null
                ? 'Select pickup date'
                : pickupDate!.toLocal().toString().split(' ')[0]),
            _buildInputBox(pickupTime == null
                ? 'Select pickup time'
                : pickupTime!.format(context)),
          ]
        ],
      ),
    );
  }

  Widget _toggleButton(String text, bool provider) {
    final isSelected = isServiceProvider == provider;
    return GestureDetector(
      onTap: () {
        setState(() {
          isServiceProvider = provider;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
