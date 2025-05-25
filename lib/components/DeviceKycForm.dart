import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class DeviceKycForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;

  const DeviceKycForm({
    super.key,
    required this.onFormChanged,
  });

  @override
  State<DeviceKycForm> createState() => _DeviceKycFormState();
}

class _DeviceKycFormState extends State<DeviceKycForm> {
  final TextEditingController modelController = TextEditingController();
  final TextEditingController lockCodeController = TextEditingController();
  
  bool isOnWarranty = false;
  DateTime? warrantyDate;
  List<String> problemsList = [];
  List<String> additionalAccessories = [];
  List<String> standardAccessories = ['Power Adapter', 'Mouse', 'Keyboard'];
  
  // Image files
  io.File? frontImage;
  io.File? backImage;
  io.File? leftImage;
  io.File? rightImage;
  
  // Appwrite file IDs
  String? frontImageId;
  String? backImageId;
  String? leftImageId;
  String? rightImageId;
  
  // Upload states
  bool isFrontUploading = false;
  bool isBackUploading = false;
  bool isLeftUploading = false;
  bool isRightUploading = false;
  
  final ImagePicker _picker = ImagePicker();
  
  // Appwrite configuration
  late Client client;
  late Storage storage;
  
  // Replace these with your Appwrite configuration
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '682ed1b4000f293ec42e';
  static const String bucketId = '68317907003109c61482';

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
    modelController.addListener(_notifyParent);
    lockCodeController.addListener(_notifyParent);
  }

  void _initializeAppwrite() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);
    
    storage = Storage(client);
  }

  @override
  void dispose() {
    modelController.dispose();
    lockCodeController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onFormChanged({
      'model': modelController.text,
      'lockCode': lockCodeController.text,
      'isOnWarranty': isOnWarranty,
      'warrantyDate': warrantyDate,
      'problemsList': problemsList,
      'additionalAccessories': additionalAccessories,
      'standardAccessories': standardAccessories,
      'frontImageId': frontImageId,
      'backImageId': backImageId,
      'leftImageId': leftImageId,
      'rightImageId': rightImageId,
      'frontImagePath': frontImage?.path,
      'backImagePath': backImage?.path,
      'leftImagePath': leftImage?.path,
      'rightImagePath': rightImage?.path,
    });
  }

  Future<String?> _uploadImageToAppwrite(io.File imageFile, String imageType) async {
    try {
      // Generate unique file ID
      final String fileId = '${DateTime.now().millisecondsSinceEpoch}_$imageType';
      
      // Create InputFile from File
      final inputFile = InputFile.fromPath(
        path: imageFile.path,
        filename: '$fileId.jpg',
      );
      
      // Upload file to Appwrite storage
      final models.File uploadedFile = await storage.createFile(
        bucketId: bucketId,
        fileId: fileId,
        file: inputFile,
      );
      
      return uploadedFile.$id;
    } catch (e) {
      print('Error uploading image: $e');
      _showSnackBar('Failed to upload image: ${e.toString()}', isError: true);
      return null;
    }
  }

  Future<void> _deleteImageFromAppwrite(String fileId) async {
    try {
      await storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  String getImageUrl(String fileId) {
    return '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectWarrantyDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: warrantyDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != warrantyDate) {
      setState(() {
        warrantyDate = picked;
        _notifyParent();
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    
    if (selectedImage != null) {
      setState(() {
        switch (imageType) {
          case 'front':
            frontImage = io.File(selectedImage.path);
            isFrontUploading = true;
            break;
          case 'back':
            backImage = io.File(selectedImage.path);
            isBackUploading = true;
            break;
          case 'left':
            leftImage = io.File(selectedImage.path);
            isLeftUploading = true;
            break;
          case 'right':
            rightImage = io.File(selectedImage.path);
            isRightUploading = true;
            break;
        }
      });

      // Upload to Appwrite
      final String? uploadedFileId = await _uploadImageToAppwrite(
        io.File(selectedImage.path),
        imageType,
      );

      setState(() {
        switch (imageType) {
          case 'front':
            isFrontUploading = false;
            if (uploadedFileId != null) {
              // Delete old file if exists
              if (frontImageId != null) {
                _deleteImageFromAppwrite(frontImageId!);
              }
              frontImageId = uploadedFileId;
              _showSnackBar('Front image uploaded successfully!');
            }
            break;
          case 'back':
            isBackUploading = false;
            if (uploadedFileId != null) {
              if (backImageId != null) {
                _deleteImageFromAppwrite(backImageId!);
              }
              backImageId = uploadedFileId;
              _showSnackBar('Back image uploaded successfully!');
            }
            break;
          case 'left':
            isLeftUploading = false;
            if (uploadedFileId != null) {
              if (leftImageId != null) {
                _deleteImageFromAppwrite(leftImageId!);
              }
              leftImageId = uploadedFileId;
              _showSnackBar('Left image uploaded successfully!');
            }
            break;
          case 'right':
            isRightUploading = false;
            if (uploadedFileId != null) {
              if (rightImageId != null) {
                _deleteImageFromAppwrite(rightImageId!);
              }
              rightImageId = uploadedFileId;
              _showSnackBar('Right image uploaded successfully!');
            }
            break;
        }
        _notifyParent();
      });
    }
  }

  Future<void> _removeImage(String imageType) async {
    String? fileIdToDelete;
    
    setState(() {
      switch (imageType) {
        case 'front':
          frontImage = null;
          fileIdToDelete = frontImageId;
          frontImageId = null;
          break;
        case 'back':
          backImage = null;
          fileIdToDelete = backImageId;
          backImageId = null;
          break;
        case 'left':
          leftImage = null;
          fileIdToDelete = leftImageId;
          leftImageId = null;
          break;
        case 'right':
          rightImage = null;
          fileIdToDelete = rightImageId;
          rightImageId = null;
          break;
      }
    });

    if (fileIdToDelete != null) {
      await _deleteImageFromAppwrite(fileIdToDelete?? '');
      _showSnackBar('Image removed successfully!');
    }
    
    _notifyParent();
  }

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
                _notifyParent();
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
  
  void _removeItem(int index, List<String> itemsList, Function(List<String>) onUpdate) {
    final List<String> updatedList = [...itemsList];
    updatedList.removeAt(index);
    onUpdate(updatedList);
    _notifyParent();
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

  Widget _buildImageSlot(String label, io.File? image, Function() onTap, bool isUploading, String? imageId) {
    return Column(
      children: [
        GestureDetector(
          onTap: isUploading ? null : onTap,
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
                )
              ],
              image: image != null
                  ? DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: isUploading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : image == null
                    ? Icon(
                        Icons.add_a_photo_rounded,
                        color: Theme.of(context).primaryColor.withOpacity(0.7),
                        size: 30,
                      )
                    : Stack(
                        children: [
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => _removeImage(label.toLowerCase().replaceAll(' ', '')),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (imageId != null)
          const Text(
            'Uploaded',
            style: TextStyle(
              color: Colors.green,
              fontSize: 10,
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

  Widget _buildAccessoryCheckItem(String title) {
    final isSelected = standardAccessories.contains(title);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            standardAccessories.remove(title);
          } else {
            standardAccessories.add(title);
          }
          _notifyParent();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected ? Theme.of(context).primaryColor : Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 20, 22, 24),
            Color.fromARGB(255, 21, 23, 26),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
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
                        isFrontUploading,
                        frontImageId,
                      ),
                      _buildImageSlot(
                        'Back',
                        backImage,
                        () => _showImageSourceDialog('back'),
                        isBackUploading,
                        backImageId,
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
                        isLeftUploading,
                        leftImageId,
                      ),
                      _buildImageSlot(
                        'Right Side',
                        rightImage,
                        () => _showImageSourceDialog('right'),
                        isRightUploading,
                        rightImageId,
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

            // Warranty Section
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isOnWarranty,
                        onChanged: (value) {
                          setState(() {
                            isOnWarranty = value!;
                            if (!isOnWarranty) {
                              warrantyDate = null;
                            }
                            _notifyParent();
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
                  if (isOnWarranty) ...[
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: _selectWarrantyDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              warrantyDate != null
                                  ? 'Warranty Expires: ${_formatDate(warrantyDate!)}'
                                  : 'Select Warranty Expiry Date',
                              style: TextStyle(
                                color: warrantyDate != null ? Colors.white : Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withOpacity(0.5),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}