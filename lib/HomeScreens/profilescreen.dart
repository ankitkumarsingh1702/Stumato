import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picking

class MyProfileScreen extends StatefulWidget {
  final User? user;

  const MyProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // Controllers for editable fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _selectedBirthday;

  File? _imageFile; // Selected image file
  bool isLoading = true; // Loading state
  bool isUpdating = false; // Update in progress

  String? profilePicUrl; // URL of the profile picture

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    if (widget.user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('user_stumato')
          .doc(widget.user!.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data();
        setState(() {
          _firstNameController.text = data?['first_name'] ?? '';
          _lastNameController.text = data?['last_name'] ?? '';
          _phoneNumberController.text = data?['phone_number'] ?? '';
          _emailController.text = data?['email'] ?? '';
          profilePicUrl = data?['profile_pic_url'];
          if (data?['birthday'] != null) {
            _selectedBirthday = DateTime.parse(data!['birthday']);
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
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
  Future<String?> _uploadImage(File image) async {
    try {
      String fileName =
          'profile_pictures/${widget.user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  // Function to select birthday
  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  // Input Validation Function
  bool _validateInputs() {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Phone number validation
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(_phoneNumberController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  // Function to update profile
  Future<void> _updateProfile() async {
    // Input Validation
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    String? imageUrl = profilePicUrl;

    // If a new image is selected, upload it
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
      if (imageUrl == null) {
        // Image upload failed
        setState(() {
          isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Prepare data to update
    Map<String, dynamic> updatedData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone_number': _phoneNumberController.text.trim(),
      'email': _emailController.text.trim(),
      'birthday': _selectedBirthday?.toIso8601String(),
      'profile_pic_url': imageUrl,
      'updated_at': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('user_stumato')
          .doc(widget.user!.uid)
          .update(updatedData);

      // If email is changed, update FirebaseAuth user email
      if (widget.user!.email != _emailController.text.trim()) {
        await widget.user!.updateEmail(_emailController.text.trim());
      }

      setState(() {
        isUpdating = false;
        _imageFile = null; // Reset image file after successful update
        profilePicUrl = imageUrl; // Update profilePicUrl
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isUpdating = false;
      });
      print('Error updating email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating email: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set entire background to white
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.figtree(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor:  const Color(0xFFEE764D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture with Camera Icon
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (profilePicUrl != null
                        ? NetworkImage(profilePicUrl!)
                        : const AssetImage(
                        'lib/assets/default_avatar.png')
                    as ImageProvider),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
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
              const SizedBox(height: 12),
              // Displaying the complete full name (first name + last name)
              Text(
                '${_firstNameController.text} ${_lastNameController.text}',
                style: GoogleFonts.figtree(
                  fontSize: 24,
                  fontWeight: FontWeight.bold, // Bold text
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Edit Profile',
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Editable Profile Fields
              _buildEditableField(
                label: 'First Name',
                controller: _firstNameController,
                isEditable: true,
              ),
              const SizedBox(height: 15),
              _buildEditableField(
                label: 'Last Name',
                controller: _lastNameController,
                isEditable: true,
              ),
              const SizedBox(height: 15),
              _buildEditableField(
                label: 'E-mail',
                controller: _emailController,
                isEditable: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              _buildEditableField(
                label: 'Phone Number',
                controller: _phoneNumberController,
                isEditable: false, // Make phone number non-editable
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              // Birthday Picker
              GestureDetector(
                onTap: () => _selectBirthday(context),
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedBirthday != null
                            ? '${_selectedBirthday!.toLocal()}'
                            .split(' ')[0]
                            : 'Select Your Birthday',
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Bold text
                          color: _selectedBirthday != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Update Button
              isUpdating
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE764D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'Update',
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Bold text
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for editable profile fields
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Slightly off-white
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isEditable ? const Color(0xFFEE764D) : Colors.grey.shade300,
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
      child: TextField(
        controller: controller,
        readOnly: !isEditable,
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
      ),
    );
  }
}
