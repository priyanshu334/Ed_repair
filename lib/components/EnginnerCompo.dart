import 'package:ed_repair/services/engineer_service.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';

class EngineerSelectorPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelectionChanged;
  final Map<String, dynamic> initialSelection; // <--- ADD THIS

  const EngineerSelectorPage({
    super.key,
    required this.onSelectionChanged,
    required this.initialSelection, // <--- ADD THIS
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
    // --- Initialize state with initialSelection ---
    if (widget.initialSelection.isNotEmpty) {
      selectedEngineer = widget.initialSelection['engineer'] as String?;
      if (widget.initialSelection['date'] != null) {
        selectedDate = DateTime.tryParse(widget.initialSelection['date']);
      }
      if (widget.initialSelection['time'] != null) {
        // Parse TimeOfDay from string (e.g., "10:30 AM")
        try {
          final String timeString = widget.initialSelection['time'];
          final List<String> parts = timeString.split(' ');
          if (parts.length == 2) {
            final List<String> hourMinute = parts[0].split(':');
            if (hourMinute.length == 2) {
              int hour = int.parse(hourMinute[0]);
              int minute = int.parse(hourMinute[1]);
              if (parts[1] == 'PM' && hour < 12) {
                hour += 12;
              } else if (parts[1] == 'AM' && hour == 12) {
                hour = 0; // Midnight
              }
              selectedTime = TimeOfDay(hour: hour, minute: minute);
            }
          }
        } catch (e) {
          debugPrint('Error parsing TimeOfDay: $e');
        }
      }
      // Notify parent immediately after initial load if there's existing data
      // This ensures that `_hasChanges` is correctly reflected in the parent.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyParent();
      });
    }
  }

  Future<void> _fetchEngineers() async {
    try {
      final List<Document> engineerDocs = await _engineerService.getAllEngineers();
      setState(() {
        engineers = engineerDocs.map((doc) => doc.data['name'] as String).toList();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) { // Check if the widget is still in the tree before calling setState
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load engineers: $e')),
        );
      }
    }
  }

  void _notifyParent() {
    final selectionData = {
      'engineer': selectedEngineer,
      'date': selectedDate?.toIso8601String(),
      'time': selectedTime?.format(context),
      'isComplete': selectedEngineer != null && selectedDate != null && selectedTime != null,
    };

    // Ensure we're passing non-null values for the map keys to avoid issues
    // with `_sanitizeDataForJson` expecting the keys to exist, even if values are null.
    // Or, allow `_sanitizeDataForJson` to handle null values gracefully.
    // Given `_sanitizeDataForJson` just checks for `null` and copies, this is fine.
    widget.onSelectionChanged(selectionData);
  }

  // Add method to clear selection
  void _clearSelection() {
    setState(() {
      selectedEngineer = null;
      selectedDate = null;
      selectedTime = null;
    });
    widget.onSelectionChanged({
      'engineer': null,
      'date': null,
      'time': null,
      'isComplete': false,
    });
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Engineer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: _clearSelection,
                          icon: const Icon(Icons.clear, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
          // Replace IconButton with circular icon matching ServiceCenterSelectorPage
          GestureDetector(
            onTap: _openDialog,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.engineering,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            selectedEngineer != null 
                ? 'Change Engineer' 
                : 'Select Engineer',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}