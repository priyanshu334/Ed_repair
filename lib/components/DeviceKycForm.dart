import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class DeviceKycForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;
  final Map<String, dynamic>? initialData; // <<< ADDED: Initial data parameter

  const DeviceKycForm({
    super.key,
    required this.onFormChanged,
    this.initialData, // <<< ADDED
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
  List<String> standardAccessories = ['Power Adapter', 'Mouse', 'Keyboard']; // Default

  // Image files (local display after picking, not for re-hydrating from initialData path directly)
  io.File? frontImage;
  io.File? backImage;
  io.File? leftImage;
  io.File? rightImage;

  // Appwrite file IDs
  String? frontImageId;
  String? backImageId;
  String? leftImageId;
  String? rightImageId;

  // Local image paths (primarily to be sent back up if no new image is picked)
  String? _initialFrontImagePath;
  String? _initialBackImagePath;
  String? _initialLeftImagePath;
  String? _initialRightImagePath;


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
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1'; // Example endpoint
  static const String projectId = '682ed1b4000f293ec42e'; // Example project ID
  static const String bucketId = '68317907003109c61482'; // Example bucket ID

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
    _loadInitialData(); // <<< ADDED: Load initial data
    modelController.addListener(_notifyParent);
    lockCodeController.addListener(_notifyParent);
  }

  void _initializeAppwrite() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);
    storage = Storage(client);
  }

  void _loadInitialData() { // <<< ADDED: Method to process initial data
    if (widget.initialData != null) {
      final data = widget.initialData!;
      modelController.text = data['model'] ?? '';
      lockCodeController.text = data['lockCode'] ?? '';
      isOnWarranty = data['isOnWarranty'] ?? false;

      if (data['warrantyDate'] != null && data['warrantyDate'] is String) {
        warrantyDate = DateTime.tryParse(data['warrantyDate']);
      } else if (data['warrantyDate'] != null && data['warrantyDate'] is DateTime) {
        warrantyDate = data['warrantyDate'];
      }


      if (data['problemsList'] != null) {
        problemsList = List<String>.from(data['problemsList']);
      }
      if (data['additionalAccessories'] != null) {
        additionalAccessories = List<String>.from(data['additionalAccessories']);
      }
      // For standardAccessories, initialData should override the default if provided
      if (data['standardAccessories'] != null) {
        standardAccessories = List<String>.from(data['standardAccessories']);
      }

      frontImageId = data['frontImageId'];
      backImageId = data['backImageId'];
      leftImageId = data['leftImageId'];
      rightImageId = data['rightImageId'];

      // Store initial paths if they exist, but don't try to create io.File from them directly
      // as they might be temporary or no longer valid. They are useful if no new image is picked.
      _initialFrontImagePath = data['frontImagePath'];
      _initialBackImagePath = data['backImagePath'];
      _initialLeftImagePath = data['leftImagePath'];
      _initialRightImagePath = data['rightImagePath'];

      // Note: We don't try to re-populate io.File image objects from paths in initialData
      // because these paths might be from a previous session or temp storage.
      // The imageId is sufficient to know an image was uploaded.
      // The user can choose to upload a new image if they want to change it.
    }
  }


  @override
  void dispose() {
    modelController.removeListener(_notifyParent);
    lockCodeController.removeListener(_notifyParent);
    modelController.dispose();
    lockCodeController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onFormChanged({
      'model': modelController.text,
      'lockCode': lockCodeController.text,
      'isOnWarranty': isOnWarranty,
      'warrantyDate': warrantyDate?.toIso8601String(), // Send as ISO string
      'problemsList': problemsList,
      'additionalAccessories': additionalAccessories,
      'standardAccessories': standardAccessories,
      'frontImageId': frontImageId,
      'backImageId': backImageId,
      'leftImageId': leftImageId,
      'rightImageId': rightImageId,
      // Send current local file path if new image picked, otherwise send initial path if it existed
      'frontImagePath': frontImage?.path ?? _initialFrontImagePath,
      'backImagePath': backImage?.path ?? _initialBackImagePath,
      'leftImagePath': leftImage?.path ?? _initialLeftImagePath,
      'rightImagePath': rightImage?.path ?? _initialRightImagePath,
    });
  }

  Future<String?> _uploadImageToAppwrite(io.File imageFile, String imageType) async {
    // ... (rest of the method remains the same)
    try {
      final String fileId = ID.unique(); // Use Appwrite's ID.unique()

      final inputFile = InputFile.fromPath(
        path: imageFile.path,
        filename: '${imageType}_${fileId}.jpg', // More descriptive filename
      );

      final models.File uploadedFile = await storage.createFile(
        bucketId: bucketId,
        fileId: fileId,
        file: inputFile,
        permissions: [ // Optional: Define permissions for the uploaded file
          Permission.read(Role.any()), // Anyone can read
          // Permission.update(Role.user(userId)), // Specific user can update
          // Permission.delete(Role.user(userId)), // Specific user can delete
        ]
      );

      return uploadedFile.$id;
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        _showSnackBar('Failed to upload $imageType image: ${e.toString()}', isError: true);
      }
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
      // Optionally show a snackbar if deletion fails and it's critical
    }
  }

  String getImageUrl(String fileId) { // This can be used if you decide to display uploaded images
    return '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return; // Check if the widget is still in the tree
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
      firstDate: DateTime(2000), // Adjusted firstDate
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)), // 10 years in future
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
    final XFile? selectedImage = await _picker.pickImage(source: source, imageQuality: 70); // Added imageQuality

    if (selectedImage != null) {
      io.File imageFile = io.File(selectedImage.path);
      String? oldFileId;

      setState(() {
        switch (imageType) {
          case 'front':
            frontImage = imageFile;
            isFrontUploading = true;
            oldFileId = frontImageId;
            _initialFrontImagePath = null; // Clear initial path as new image is picked
            break;
          case 'back':
            backImage = imageFile;
            isBackUploading = true;
            oldFileId = backImageId;
            _initialBackImagePath = null;
            break;
          case 'left':
            leftImage = imageFile;
            isLeftUploading = true;
            oldFileId = leftImageId;
            _initialLeftImagePath = null;
            break;
          case 'right':
            rightImage = imageFile;
            isRightUploading = true;
            oldFileId = rightImageId;
            _initialRightImagePath = null;
            break;
        }
      });

      // Delete old file from Appwrite if it exists
      if (oldFileId != null) {
        await _deleteImageFromAppwrite(oldFileId!);
      }
      
      final String? uploadedFileId = await _uploadImageToAppwrite(imageFile, imageType);

      if (!mounted) return;

      setState(() {
        String successMessage = '';
        switch (imageType) {
          case 'front':
            isFrontUploading = false;
            if (uploadedFileId != null) frontImageId = uploadedFileId;
            successMessage = 'Front image';
            break;
          case 'back':
            isBackUploading = false;
            if (uploadedFileId != null) backImageId = uploadedFileId;
            successMessage = 'Back image';
            break;
          case 'left':
            isLeftUploading = false;
            if (uploadedFileId != null) leftImageId = uploadedFileId;
            successMessage = 'Left image';
            break;
          case 'right':
            isRightUploading = false;
            if (uploadedFileId != null) rightImageId = uploadedFileId;
            successMessage = 'Right image';
            break;
        }
        if (uploadedFileId != null) {
          _showSnackBar('$successMessage uploaded successfully!');
        } else {
          // Clear local file if upload failed
           switch (imageType) {
            case 'front': frontImage = null; break;
            case 'back': backImage = null; break;
            case 'left': leftImage = null; break;
            case 'right': rightImage = null; break;
          }
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
          fileIdToDelete = frontImageId;
          frontImage = null;
          frontImageId = null;
          _initialFrontImagePath = null;
          break;
        case 'back':
          fileIdToDelete = backImageId;
          backImage = null;
          backImageId = null;
          _initialBackImagePath = null;
          break;
        case 'left':
          fileIdToDelete = leftImageId;
          leftImage = null;
          leftImageId = null;
          _initialLeftImagePath = null;
          break;
        case 'right':
          fileIdToDelete = rightImageId;
          rightImage = null;
          rightImageId = null;
          _initialRightImagePath = null;
          break;
      }
    });

    if (fileIdToDelete != null) {
      await _deleteImageFromAppwrite(fileIdToDelete!);
      _showSnackBar('${imageType.substring(0,1).toUpperCase()}${imageType.substring(1)} image removed successfully!');
    }
    _notifyParent();
  }


  void _showImageSourceDialog(String imageType) {
    // ... (rest of the method remains the same)
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
              'Select Image Source for ${imageType.capitalizeFirst()}', // More context
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
             const SizedBox(height: 10),
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                onPressed: () => Navigator.pop(context),
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
    // ... (rest of the method remains the same)
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
    // ... (rest of the method remains the same)
     final TextEditingController itemController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Add $title'), // Modified title
        content: TextField(
          controller: itemController,
          autofocus: true, // Autofocus for better UX
          decoration: InputDecoration(
            hintText: 'Enter $title name', // More specific hint
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onSubmitted: (_) => _submitAddItem(itemController, itemsList, onUpdate), // Allow submission with Enter key
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submitAddItem(itemController, itemsList, onUpdate),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor, // Consistent styling
              foregroundColor: Colors.white,
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
  
  // Helper for _addItemDialog
  void _submitAddItem(TextEditingController controller, List<String> currentList, Function(List<String>) onUpdate) {
    if (controller.text.trim().isNotEmpty) {
      final List<String> updatedList = [...currentList, controller.text.trim()];
      onUpdate(updatedList);
      _notifyParent();
      if (mounted) Navigator.pop(context);
    } else {
       if (mounted) _showSnackBar('Item name cannot be empty', isError: true);
    }
  }

  void _removeItem(int index, List<String> itemsList, Function(List<String>) onUpdate) {
    final List<String> updatedList = [...itemsList];
    updatedList.removeAt(index);
    onUpdate(updatedList);
    _notifyParent();
  }


  Widget _buildInput(String label, TextEditingController controller, {bool obscureText = false, IconData? prefixIcon}) { // Added IconData
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white), // Ensure text input color is visible
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), // Lighter label
          hintText: 'Enter $label', // Hint text
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05), // Darker fill
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Slightly less rounded
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, color: Theme.of(context).primaryColor.withOpacity(0.8)) 
              : null,
        ),
      ),
    );
  }

  Widget _buildImageSlot(String label, io.File? imageFile, Function() onTap, bool isUploading, String? currentImageId) {
    // If an imageId exists (meaning it's uploaded) but no local imageFile is set (e.g., initial load),
    // you might want to display a placeholder or the actual image from Appwrite using getImageUrl(imageId).
    // For simplicity here, we show the local picked image, or an icon if no local image/upload in progress.
    // The 'Uploaded' text is now based on currentImageId.

    Widget content;
    if (isUploading) {
      content = Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      );
    } else if (imageFile != null) {
      content = ClipRRect( // Ensure image respects border radius
        borderRadius: BorderRadius.circular(10), // Slightly less than container for clean look
        child: Image.file(imageFile, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
      );
    } else if (currentImageId != null) { // Display placeholder if image is uploaded but not locally selected for change
        content = Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade400,
            size: 35,
        );
    }
    else {
      content = Icon(
        Icons.add_a_photo_rounded,
        color: Theme.of(context).primaryColor.withOpacity(0.7),
        size: 30,
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: isUploading ? null : onTap, // Allow tap if not uploading
          child: Container(
            height: 100,
            width: 100, // Made it square for better aspect ratio for device images
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              // Removed boxShadow for a flatter design consistent with inputs
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                content,
                if (!isUploading && (imageFile != null || currentImageId != null)) // Show remove button if image exists (local or uploaded)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(label.toLowerCase().split(' ')[0]), // Simpler key for removal
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
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
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        if (!isUploading && currentImageId != null) // Show 'Uploaded' only if ID exists and not currently uploading
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              imageFile != null ? 'Replacing' : 'Uploaded', // Indicate if replacing
              style: TextStyle(
                color: imageFile != null ? Colors.orange.shade300 : Colors.green.shade400,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // ... (rest of _buildListSection, _buildAccessoryCheckItem, and build method remain largely the same)
  // You might want to adjust styling in build method or helper widgets for consistency.
  // For example, the prefixIcons for _buildInput:
  // _buildInput('Device Model', modelController, prefixIcon: Icons.phone_android_rounded),
  // _buildInput('Lock Code', lockCodeController, obscureText: true, prefixIcon: Icons.lock_rounded),


  Widget _buildListSection(String title, List<String> items, VoidCallback onAdd, {bool isDeletable = true}) {
    // ... same logic, just ensure colors match the theme
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Consistent background
        borderRadius: BorderRadius.circular(12), // Consistent radius
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
              if (isDeletable || title == 'Problems List' || title == 'Additional Accessories') // Ensure add button appears for relevant lists
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
                      'No ${title.toLowerCase().replaceAll(' list', '')} added yet. Tap + to add.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : ListView.builder( // Using ListView.builder for consistency, though Column was also fine
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1), // Slightly different for items
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.label_important_outline_rounded, // Changed icon
                            size: 16, // Adjusted size
                            color: Theme.of(context).primaryColor.withOpacity(0.8),
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
                              icon: Icon(
                                Icons.delete_outline_rounded, // Changed icon
                                color: Colors.red.shade300,
                                size: 20, // Adjusted size
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Adjusted padding
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1), // Consistent item background
          borderRadius: BorderRadius.circular(8), // Consistent radius
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, // Changed icons
              size: 20, // Adjusted size
              color: isSelected ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.7),
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
    // Make sure the theme for this specific form has a primaryColor defined if it's used extensively.
    // Example: final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16), // Adjusted padding
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 28, 30, 33), // Slightly adjusted dark colors
            Color.fromARGB(255, 22, 24, 27),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)), // Adjusted radius
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.devices_other_rounded, color: Colors.white, size: 26), // Changed Icon
                SizedBox(width: 10),
                Text(
                  'Device Information', // Changed Title
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 20, // Adjusted Size
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Provide details and images of the device.', // Changed subtitle
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13), // Adjusted size
            ),
            const SizedBox(height: 25), // Increased spacing
            
            _buildInput('Device Model', modelController, prefixIcon: Icons.smartphone_rounded),
            _buildInput('Lock Code (if any)', lockCodeController, obscureText: true, prefixIcon: Icons.lock_outline_rounded),
            
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20), // Increased margin
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Device Images (4 Sides)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17, // Adjusted size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tap to upload. Clear photos are recommended.',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12), // Adjusted size
                  ),
                  const SizedBox(height: 20), // Increased spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use spaceEvenly for better distribution
                    children: [
                      _buildImageSlot('Front', frontImage, () => _showImageSourceDialog('front'), isFrontUploading, frontImageId),
                      _buildImageSlot('Back', backImage, () => _showImageSourceDialog('back'), isBackUploading, backImageId),
                    ],
                  ),
                  const SizedBox(height: 20), // Increased spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildImageSlot('Left Side', leftImage, () => _showImageSourceDialog('left'), isLeftUploading, leftImageId),
                      _buildImageSlot('Right Side', rightImage, () => _showImageSourceDialog('right'), isRightUploading, rightImageId),
                    ],
                  ),
                ],
              ),
            ),
            
            _buildListSection(
              'Reported Problems', // Renamed
              problemsList,
              () => _addItemDialog(
                'Problem',
                problemsList,
                (updated) => setState(() => problemsList = updated),
              ),
            ),
            
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Standard Accessories Included', // Renamed
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAccessoryCheckItem('Power Adapter/Cable'), // Updated text
                  _buildAccessoryCheckItem('Mouse (if applicable)'), // Updated text
                  _buildAccessoryCheckItem('Keyboard (if applicable)'), // Updated text
                   _buildAccessoryCheckItem('Original Box'),
                ],
              ),
            ),
            
            _buildListSection(
              'Additional Accessories',
              additionalAccessories,
              () => _addItemDialog(
                'Accessory',
                additionalAccessories,
                (updated) => setState(() => additionalAccessories = updated),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Adjusted padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row( // Wrapped Checkbox and Text in a Row for better alignment
                    children: [
                      SizedBox( // Constrain Checkbox size
                        width: 24, height: 24,
                        child: Checkbox(
                          value: isOnWarranty,
                          onChanged: (value) {
                            setState(() {
                              isOnWarranty = value ?? false; // Handle null
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
                              return Colors.transparent; // Transparent when not selected
                            },
                          ),
                          visualDensity: VisualDensity.compact, // Reduce padding around checkbox
                          checkColor: Colors.white, // Color of the check mark
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          side: BorderSide(color: isOnWarranty ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.7)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector( // Allow tapping text to toggle checkbox
                         onTap: () {
                            setState(() {
                              isOnWarranty = !isOnWarranty;
                              if (!isOnWarranty) {
                                warrantyDate = null;
                              }
                              _notifyParent();
                            });
                          },
                        child: const Text(
                          'Device under Warranty?', // Question format
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
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
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded, // Changed icon
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded( // Allow text to wrap if needed
                              child: Text(
                                warrantyDate != null
                                    ? 'Expires on: ${_formatDate(warrantyDate!)}' // Simplified text
                                    : 'Select Warranty Expiry Date',
                                style: TextStyle(
                                  color: warrantyDate != null ? Colors.white : Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Add some space before the arrow
                            Icon(
                              Icons.edit_calendar_outlined, // Changed icon
                              color: Colors.white.withOpacity(0.5),
                              size: 18, // Adjusted size
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

// Helper extension for String capitalization
extension StringExtension on String {
    String capitalizeFirst() {
      if (isEmpty) return this;
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}