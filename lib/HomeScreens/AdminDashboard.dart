import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'Add_Announcement.dart';
import 'AllStores.dart'; // For Image Picking


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Controllers for store fields
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeDescriptionController =
  TextEditingController();
  final TextEditingController _storeRatingController = TextEditingController();
  final TextEditingController _storeOrdersController =
  TextEditingController();
  final TextEditingController _storeURLController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();
  final TextEditingController _storeAgentContactController =
  TextEditingController();
  final TextEditingController _storeEmailController = TextEditingController();
  final TextEditingController _storeTimingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  File? _storeImageFile; // Selected store image file
  String? _storeImageUrl; // URL of the store image

  // Function to pick image from gallery
  Future<void> _pickStoreImage() async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);

      if (pickedFile != null) {
        setState(() {
          _storeImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to upload image to Firebase Storage and get URL
  Future<String?> _uploadStoreImage(File image) async {
    try {
      String fileName =
          'store_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(image);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Function to save store details to Firestore
  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? imageUrl = _storeImageUrl;

    // If a new image is selected, upload it
    if (_storeImageFile != null) {
      imageUrl = await _uploadStoreImage(_storeImageFile!);
      if (imageUrl == null) {
        // Image upload failed
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload store image.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Prepare data to save
    Map<String, dynamic> storeData = {
      'storeName': _storeNameController.text.trim(),
      'storeDescription':
      _storeDescriptionController.text.trim().isEmpty
          ? null
          : _storeDescriptionController.text.trim(),
      'storeRating': _storeRatingController.text.trim().isEmpty
          ? null
          : double.tryParse(_storeRatingController.text.trim()),
      'storeTotalOrders': _storeOrdersController.text.trim().isEmpty
          ? null
          : int.tryParse(_storeOrdersController.text.trim()),
      'storeURL': _storeURLController.text.trim(),
      'storeAddress': _storeAddressController.text.trim().isEmpty
          ? null
          : _storeAddressController.text.trim(),
      'storeAgentContact': _storeAgentContactController.text.trim(),
      'storeEmail': _storeEmailController.text.trim().isEmpty
          ? null
          : _storeEmailController.text.trim(),
      'storeTiming': _storeTimingController.text.trim().isEmpty
          ? null
          : _storeTimingController.text.trim(),
      'storeImageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      // Use store name as document ID to ensure uniqueness
      await FirebaseFirestore.instance
          .collection('admin_stores')
          .doc(_storeNameController.text.trim())
          .set(storeData);

      setState(() {
        _isSaving = false;
        _storeImageFile = null;
        _storeImageUrl = null;
        // Clear all fields
        _storeNameController.clear();
        _storeDescriptionController.clear();
        _storeRatingController.clear();
        _storeOrdersController.clear();
        _storeURLController.clear();
        _storeAddressController.clear();
        _storeAgentContactController.clear();
        _storeEmailController.clear();
        _storeTimingController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store added successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving store: $e');
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving store: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to delete a store
  Future<void> _deleteStore(String storeName) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin_stores')
          .doc(storeName)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting store: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting store: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget to build the form for adding a new store
  Widget _buildAddStoreForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Store Image with Add Icon
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _storeImageFile != null
                    ? FileImage(_storeImageFile!)
                    : (_storeImageUrl != null
                    ? NetworkImage(_storeImageUrl!)
                    : const AssetImage('assets/default_store.png')
                as ImageProvider),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickStoreImage,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.camera_alt,
                      color: const Color(0xFFEE764D),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Store Name
          _buildInputField(
            label: 'Store Name',
            controller: _storeNameController,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 15),
          // Store Description
          _buildInputField(
            label: 'Store Description (Optional)',
            controller: _storeDescriptionController,
            keyboardType: TextInputType.text,
            isOptional: true,
          ),
          const SizedBox(height: 15),
          // Store Rating
          _buildInputField(
            label: 'Store Rating (Optional)',
            controller: _storeRatingController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isOptional: true,
          ),
          const SizedBox(height: 15),
          // Store Total Orders
          _buildInputField(
            label: 'Store Total Orders (Optional)',
            controller: _storeOrdersController,
            keyboardType: TextInputType.number,
            isOptional: true,
          ),
          const SizedBox(height: 15),
          // Store URL
          _buildInputField(
            label: 'Store URL',
            controller: _storeURLController,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 15),
          // Store Current Address
          _buildInputField(
            label: 'Store Current Address (Optional)',
            controller: _storeAddressController,
            keyboardType: TextInputType.text,
            isOptional: true,
          ),
          const SizedBox(height: 15),
          // Store Agent Contact
          _buildInputField(
            label: 'Store Agent Contact',
            controller: _storeAgentContactController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          // Store Email
          _buildInputField(
            label: 'Store Email (Optional)',
            controller: _storeEmailController,
            keyboardType: TextInputType.emailAddress,
            isOptional: true,
          ),
          const SizedBox(height: 15),
          // Store Timing
          _buildInputField(
            label: 'Store Timing (Optional)',
            controller: _storeTimingController,
            keyboardType: TextInputType.text,
            isOptional: true,
          ),
          const SizedBox(height: 30),
          // Save Button
          _isSaving
              ? const CircularProgressIndicator()
              : SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _saveStore,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFEE764D), // Match AppBar color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.figtree(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for input fields similar to MyProfileScreen
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false, // Added parameter to indicate optional fields
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Slightly off-white
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.figtree(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold, // Bold label
          ),
          border: InputBorder.none,
        ),
        style: GoogleFonts.figtree(
          fontSize: 16,
          fontWeight: FontWeight.normal, // Normal text
          color: Colors.black,
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          if (label.contains('Email') &&
              value != null &&
              value.trim().isNotEmpty) {
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
              return 'Please enter a valid email';
            }
          }
          if (label.contains('Rating') &&
              value != null &&
              value.trim().isNotEmpty) {
            double? rating = double.tryParse(value.trim());
            if (rating == null || rating < 0 || rating > 5) {
              return 'Please enter a rating between 0 and 5';
            }
          }
          if (label.contains('Contact') &&
              value != null &&
              value.trim().isNotEmpty) {
            if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value.trim())) {
              return 'Please enter a valid phone number';
            }
          }
          if (label.contains('URL') &&
              value != null &&
              value.trim().isNotEmpty) {
            if (!(Uri.tryParse(value.trim())?.hasAbsolutePath ?? false)) {
              return 'Please enter a valid URL';
            }
          }
          return null;
        },
      ),
    );
  }

  // Widget to build the list of stores
  Widget _buildStoreList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('admin_stores')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching stores.'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stores = snapshot.data!.docs;

        if (stores.isEmpty) {
          return const Center(
            child: Text('No stores available.'),
          );
        }

        return ListView.builder(
          itemCount: stores.length,
          itemBuilder: (context, index) {
            var store = stores[index].data() as Map<String, dynamic>;
            String storeName = store['storeName'] ?? 'Unnamed Store';
            String? storeImageUrl = store['storeImageUrl'];
            String? storeURL = store['storeURL'];
            String? storeDescription = store['storeDescription'];
            double? storeRating = store['storeRating'];
            int? storeTotalOrders = store['storeTotalOrders'];
            String? storeAddress = store['storeAddress'];
            String? storeAgentContact = store['storeAgentContact'];
            String? storeEmail = store['storeEmail'];
            String? storeTiming = store['storeTiming'];

            return GestureDetector(
              onLongPress: () {
                // Show delete confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Store'),
                    content: Text(
                        'Are you sure you want to delete the store "$storeName"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteStore(storeName);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Card(
                elevation: 3,
                margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: storeImageUrl != null
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(storeImageUrl),
                    radius: 25,
                  )
                      : const CircleAvatar(
                    child: Icon(Icons.store),
                    radius: 25,
                  ),
                  title: Text(
                    storeName,
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (storeDescription != null)
                        Text(
                          storeDescription,
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      if (storeURL != null)
                        Text(
                          storeURL,
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      if (storeRating != null)
                        Text(
                          'Rating: $storeRating',
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      if (storeTotalOrders != null)
                        Text(
                          'Total Orders: $storeTotalOrders',
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      if (storeAddress != null)
                        Text(
                          'Address: $storeAddress',
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      if (storeAgentContact != null)
                        Text(
                          'Agent Contact: $storeAgentContact',
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      if (storeEmail != null)
                        Text(
                          'Email: $storeEmail',
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      if (storeTiming != null)
                        Text(
                          'Timing: $storeTiming',
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.delete, color: Colors.red),
                  onTap: () {
                    // Optionally, implement store detail view
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Function to navigate to AddAnnouncement.dart
  void _navigateToAddAnnouncement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAnnouncement()),
    );
  }

  // Function to show the list of stores by navigating to AllStores.dart
  void _navigateToAllStores() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllStores()),
    );
  }

  // Widget to build the main dashboard
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match the profile screen's background
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.figtree(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEE764D), // Consistent AppBar color
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert),
            onPressed: _navigateToAddAnnouncement, // Navigate to AddAnnouncement.dart
            tooltip: 'Add Announcement',
          ),
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: _navigateToAllStores, // Navigate to AllStores.dart
            tooltip: 'View All Stores',
          ),

        ],
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            // Implement logout functionality if needed
            // Example:
            // await FirebaseAuth.instance.signOut();
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Add New Store',
                    style: GoogleFonts.figtree(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fill in the details below to add a new store.',
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Add Store Form
                  _buildAddStoreForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
