import 'package:ed_repair/components/PatterLockPage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DeviceKycForm extends StatefulWidget {
  const DeviceKycForm({super.key});

  @override
  State<DeviceKycForm> createState() => _DeviceKycFormState();
}

class _DeviceKycFormState extends State<DeviceKycForm> {
  final TextEditingController modelController = TextEditingController();
  final TextEditingController lockCodeController = TextEditingController();
  
  bool isOnWarranty = false;
  List<String> problemsList = [];
  List<String> additionalAccessories = [];
  
  // Image files
  File? frontImage;
  File? backImage;
  File? leftImage;
  File? rightImage;
  
  final ImagePicker _picker = ImagePicker();

  // Function to pick image
  Future<void> _pickImage(ImageSource source, String imageType) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    
    if (selectedImage != null) {
      setState(() {
        switch (imageType) {
          case 'front':
            frontImage = File(selectedImage.path);
            break;
          case 'back':
            backImage = File(selectedImage.path);
            break;
          case 'left':
            leftImage = File(selectedImage.path);
            break;
          case 'right':
            rightImage = File(selectedImage.path);
            break;
        }
      });
    }
  }
  
  // Function to show image source options
  void _showImageSourceDialog(String imageType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, imageType);
                  },
                ),
                _imageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, imageType);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Function to add items to lists
  void _addItemDialog(String title, List<String> itemsList, Function(List<String>) onUpdate) {
    final TextEditingController itemController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title),
        content: TextField(
          controller: itemController,
          decoration: InputDecoration(
            hintText: 'Enter $title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (itemController.text.trim().isNotEmpty) {
                final List<String> updatedList = [...itemsList, itemController.text.trim()];
                onUpdate(updatedList);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  // Function to remove items from lists
  void _removeItem(int index, List<String> itemsList, Function(List<String>) onUpdate) {
    final List<String> updatedList = [...itemsList];
    updatedList.removeAt(index);
    onUpdate(updatedList);
  }

  Widget _buildInput(String label, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.8)),
          hintText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          prefixIcon: label == 'Device Model' 
              ? const Icon(Icons.phone_android_rounded) 
              : (label == 'Lock Code' ? const Icon(Icons.lock_rounded) : null),
        ),
      ),
    );
  }

  Widget _buildImageSlot(String label, File? image, Function() onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
              image: image != null
                  ? DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: image == null
                ? Icon(
                    Icons.add_a_photo_rounded,
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                    size: 30,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items, VoidCallback onAdd, {bool isDeletable = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onAdd,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'No items added yet. Tap + to add.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              items[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          if (isDeletable)
                            IconButton(
                              onPressed: () => title == 'Problems List'
                                  ? _removeItem(
                                      index,
                                      problemsList,
                                      (updated) => setState(() => problemsList = updated),
                                    )
                                  : _removeItem(
                                      index,
                                      additionalAccessories,
                                      (updated) => setState(() => additionalAccessories = updated),
                                    ),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E2837),
            const Color(0xFF2A3A4D),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  'Device KYC',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 22, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Complete the form below with device details',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            _buildInput('Device Model', modelController),
            _buildInput('Lock Code', lockCodeController, obscureText: true),
            
            // Pattern Lock Button
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to pattern lock page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatternLockPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.grid_3x3),
                label: const Text(
                  'Set Pattern Lock',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Device Images Section
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Device Images',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tap to upload clear photos of your device',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildImageSlot(
                        'Front',
                        frontImage,
                        () => _showImageSourceDialog('front'),
                      ),
                      _buildImageSlot(
                        'Back',
                        backImage,
                        () => _showImageSourceDialog('back'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildImageSlot(
                        'Left Side',
                        leftImage,
                        () => _showImageSourceDialog('left'),
                      ),
                      _buildImageSlot(
                        'Right Side',
                        rightImage,
                        () => _showImageSourceDialog('right'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Problems List
            _buildListSection(
              'Problems List',
              problemsList,
              () => _addItemDialog(
                'Problem',
                problemsList,
                (updated) => setState(() => problemsList = updated),
              ),
            ),
            
            // Standard Accessories Section
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Standard Accessories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAccessoryCheckItem('Power Adapter'),
                  _buildAccessoryCheckItem('Mouse'),
                  _buildAccessoryCheckItem('Keyboard'),
                ],
              ),
            ),
            
            // Additional Accessories
            _buildListSection(
              'Additional Accessories',
              additionalAccessories,
              () => _addItemDialog(
                'Accessory',
                additionalAccessories,
                (updated) => setState(() => additionalAccessories = updated),
              ),
            ),

            // Warranty Checkbox
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isOnWarranty,
                    onChanged: (value) {
                      setState(() {
                        isOnWarranty = value!;
                      });
                    },
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context).primaryColor;
                        }
                        return Colors.transparent;
                      },
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Device on Warranty',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            // Submit Button
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 55,
              margin: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                onPressed: () {
                  // Handle form submission
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Device KYC submitted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAccessoryCheckItem(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// Pattern Lock Page
