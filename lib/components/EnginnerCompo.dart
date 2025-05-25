import 'package:ed_repair/services/engineer_service.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';

class EngineerSelectorPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelectionChanged;

  const EngineerSelectorPage({
    super.key,
    required this.onSelectionChanged,
  });

  @override
  State<EngineerSelectorPage> createState() => _EngineerSelectorPageState();
}

class _EngineerSelectorPageState extends State<EngineerSelectorPage> {
  String? selectedEngineer;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<String> engineers = [];
  bool isLoading = true;

  final EngineerService _engineerService = EngineerService();

  @override
  void initState() {
    super.initState();
    _fetchEngineers();
  }

  Future<void> _fetchEngineers() async {
    try {
      final List<Document> engineerDocs = await _engineerService.getAllEngineers();
      setState(() {
        engineers = engineerDocs.map((doc) => doc.data['name'] as String).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load engineers: $e')),
      );
    }
  }

  void _notifyParent() {
    final selectionData = {
      'engineer': selectedEngineer,
      'date': selectedDate?.toIso8601String(),
      'time': selectedTime?.format(context),
      'isComplete': selectedEngineer != null && selectedDate != null && selectedTime != null,
    };
    
    widget.onSelectionChanged(selectionData);
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
                    Icons.engineering,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Select Engineer',
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
                    // Engineer Dropdown
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonFormField<String>(
                              value: selectedEngineer,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.person),
                                hintText: 'Choose Engineer',
                              ),
                              items: engineers
                                  .map((eng) => DropdownMenuItem(
                                        value: eng,
                                        child: Text(eng),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedEngineer = value;
                                });
                                setState(() {
                                  selectedEngineer = value;
                                });
                                _notifyParent();
                              },
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Date Picker
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
                            });
                            _notifyParent();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Picker
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
                            });
                            _notifyParent();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedEngineer != null || selectedDate != null || selectedTime != null)
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
                    if (selectedEngineer != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.engineering, 
                                size: 20, 
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              selectedEngineer!,
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
            icon: const Icon(Icons.engineering),
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