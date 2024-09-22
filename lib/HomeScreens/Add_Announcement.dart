import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // For file picking

class AddAnnouncement extends StatefulWidget {
  const AddAnnouncement({Key? key}) : super(key: key);

  @override
  State<AddAnnouncement> createState() => _AddAnnouncementState();
}

class _AddAnnouncementState extends State<AddAnnouncement> {
  // Controllers for announcement fields
  final TextEditingController _announcementHeadingController =
  TextEditingController();
  final TextEditingController _announcementContentController =
  TextEditingController();
  final TextEditingController _publishedByController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  File? _announcementImageFile; // Selected announcement image file
  String? _announcementImageUrl; // URL of the announcement image

  File? _announcementDataFile; // Selected announcement data file
  String? _announcementDataUrl; // URL of the announcement data

  String? _selectedCategory;
  List<String> _categories = ['General', 'Updates', 'Events']; // Initial categories

  // Function to pick image from gallery
  Future<void> _pickAnnouncementImage() async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);

      if (pickedFile != null) {
        setState(() {
          _announcementImageFile = File(pickedFile.path);
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

  // Function to pick announcement data file (e.g., PDF)
  Future<void> _pickAnnouncementData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _announcementDataFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to upload image to Firebase Storage and get URL
  Future<String?> _uploadAnnouncementImage(File image) async {
    try {
      String fileName =
          'announcement_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  // Function to upload announcement data file to Firebase Storage and get URL
  Future<String?> _uploadAnnouncementData(File file) async {
    try {
      String fileName =
          'announcement_data/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Function to save announcement details to Firestore
  Future<void> _saveAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? imageUrl = _announcementImageUrl;
    String? dataUrl = _announcementDataUrl;

    // If a new image is selected, upload it
    if (_announcementImageFile != null) {
      imageUrl = await _uploadAnnouncementImage(_announcementImageFile!);
      if (imageUrl == null) {
        // Image upload failed
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload announcement image.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // If a new data file is selected, upload it
    if (_announcementDataFile != null) {
      dataUrl = await _uploadAnnouncementData(_announcementDataFile!);
      if (dataUrl == null) {
        // File upload failed
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload announcement data file.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Prepare data to save
    Map<String, dynamic> announcementData = {
      'category': _selectedCategory,
      'heading': _announcementHeadingController.text.trim(),
      'content': _announcementContentController.text.trim().isEmpty
          ? null
          : _announcementContentController.text.trim(),
      'imageUrl': imageUrl,
      'dataUrl': dataUrl,
      'publishedBy': _publishedByController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .add(announcementData);

      setState(() {
        _isSaving = false;
        _announcementImageFile = null;
        _announcementImageUrl = null;
        _announcementDataFile = null;
        _announcementDataUrl = null;
        _selectedCategory = null;
        // Clear all fields
        _announcementHeadingController.clear();
        _announcementContentController.clear();
        _publishedByController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement added successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving announcement: $e');
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving announcement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to add a new category
  Future<void> _addNewCategory() async {
    String? newCategory;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Category Name',
          ),
          onChanged: (value) {
            newCategory = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (newCategory != null &&
                  newCategory!.trim().isNotEmpty &&
                  !_categories.contains(newCategory!.trim())) {
                setState(() {
                  _categories.add(newCategory!.trim());
                  _selectedCategory = newCategory!.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Widget to build the form for adding a new announcement
  Widget _buildAddAnnouncementForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Announcement Image with Add Icon
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _announcementImageFile != null
                    ? FileImage(_announcementImageFile!)
                    : (_announcementImageUrl != null
                    ? NetworkImage(_announcementImageUrl!)
                    : const AssetImage('assets/default_announcement.png')
                as ImageProvider),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAnnouncementImage,
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
          // Category Dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('Select Category'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNewCategory,
                  tooltip: 'Add New Category',
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Announcement Heading
          _buildInputField(
            label: 'Announcement Heading',
            controller: _announcementHeadingController,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 15),
          // Announcement Content (Optional)
          _buildInputField(
            label: 'Announcement Content (Optional)',
            controller: _announcementContentController,
            keyboardType: TextInputType.multiline,
            isOptional: true,
            maxLines: 4,
          ),
          const SizedBox(height: 15),
          // Announcement Data File Picker
          Container(
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _announcementDataFile != null
                        ? 'Selected File: ${_announcementDataFile!.path.split('/').last}'
                        : 'No file selected',
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickAnnouncementData,
                  tooltip: 'Attach File',
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Published By
          _buildInputField(
            label: 'Published By',
            controller: _publishedByController,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 30),
          // Save Button
          _isSaving
              ? const CircularProgressIndicator()
              : SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _saveAnnouncement,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFEE764D), // Match AppBar color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                'Save Announcement',
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

  // Widget for input fields similar to AdminDashboard
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false, // Added parameter to indicate optional fields
    int maxLines = 1,
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
        maxLines: maxLines,
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

  // Widget to build the list of announcements
  Widget _buildAnnouncementList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching announcements.'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final announcements = snapshot.data!.docs;

        if (announcements.isEmpty) {
          return const Center(
            child: Text('No announcements available.'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            var announcement =
            announcements[index].data() as Map<String, dynamic>;
            String heading = announcement['heading'] ?? 'No Heading';
            String? content = announcement['content'];
            String? imageUrl = announcement['imageUrl'];
            String? dataUrl = announcement['dataUrl'];
            String publishedBy = announcement['publishedBy'] ?? 'Unknown';
            Timestamp? createdAt = announcement['createdAt'];

            DateTime? createdDate =
            createdAt != null ? createdAt.toDate() : null;

            return GestureDetector(
              onLongPress: () {
                // Show update/delete options
                _showAnnouncementOptions(announcements[index].id, announcement);
              },
              child: Card(
                elevation: 3,
                margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: imageUrl != null
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 25,
                  )
                      : const CircleAvatar(
                    child: Icon(Icons.announcement),
                    radius: 25,
                  ),
                  title: Text(
                    heading,
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content != null)
                        Text(
                          content,
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      if (dataUrl != null)
                        GestureDetector(
                          onTap: () {
                            // Implement file opening if needed
                          },
                          child: Text(
                            'Attached File',
                            style: GoogleFonts.figtree(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      Text(
                        'Published by: $publishedBy',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      if (createdDate != null)
                        Text(
                          'Created at: ${createdDate.toLocal()}',
                          style: GoogleFonts.figtree(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    // Optionally, implement announcement detail view
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Function to show options for an announcement (Update/Delete)
  void _showAnnouncementOptions(String docId, Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Update Announcement'),
            onTap: () {
              Navigator.pop(context);
              _showUpdateAnnouncementDialog(docId, announcement);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Announcement'),
            onTap: () {
              Navigator.pop(context);
              _deleteAnnouncement(docId);
            },
          ),
        ],
      ),
    );
  }

  // Function to delete an announcement
  Future<void> _deleteAnnouncement(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting announcement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting announcement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to show update announcement dialog
  void _showUpdateAnnouncementDialog(String docId, Map<String, dynamic> announcement) {
    // You can implement this function to allow updating the announcement
    // For brevity, it's not fully implemented here
    // It would involve showing a form similar to the add form, pre-filled with existing data
  }

  // Function to show all announcements in a new screen
  void _navigateToAllAnnouncements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllAnnouncements()),
    );
  }

  // Widget to build the main AddAnnouncement screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Consistent background
      appBar: AppBar(
        title: Text(
          'Add Announcement',
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
            icon: const Icon(Icons.list),
            onPressed: _navigateToAllAnnouncements, // Navigate to AllAnnouncements.dart
            tooltip: 'View All Announcements',
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                    'Add New Announcement',
                    style: GoogleFonts.figtree(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fill in the details below to add a new announcement.',
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Add Announcement Form
                  _buildAddAnnouncementForm(),
                  const SizedBox(height: 30),
                  // List of Announcements
                  Text(
                    'All Announcements',
                    style: GoogleFonts.figtree(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildAnnouncementList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder for AllAnnouncements screen
class AllAnnouncements extends StatelessWidget {
  const AllAnnouncements({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // You can implement a separate screen to list all announcements
    // For brevity, this is left as a placeholder
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Announcements'),
        backgroundColor: const Color(0xFFEE764D),
      ),
      body: const Center(
        child: Text('All Announcements List Here'),
      ),
    );
  }
}
