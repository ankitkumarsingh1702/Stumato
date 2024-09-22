import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllStores extends StatelessWidget {
  const AllStores({Key? key}) : super(key: key);

  // Function to delete a store
  Future<void> _deleteStore(BuildContext context, String storeName) async {
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

  // Function to edit a store
  Future<void> _editStore(BuildContext context, String storeName, Map<String, dynamic> storeData) async {
    final _formKey = GlobalKey<FormState>();
    // Initialize controllers with existing data
    final TextEditingController storeNameController = TextEditingController(text: storeName);
    final TextEditingController storeURLController = TextEditingController(text: storeData['storeURL'] ?? '');
    final TextEditingController storeDescriptionController = TextEditingController(text: storeData['storeDescription'] ?? '');
    final TextEditingController storeRatingController = TextEditingController(text: storeData['storeRating']?.toString() ?? '');
    final TextEditingController storeTotalOrdersController = TextEditingController(text: storeData['storeTotalOrders']?.toString() ?? '');
    final TextEditingController storeAddressController = TextEditingController(text: storeData['storeAddress'] ?? '');
    final TextEditingController storeAgentContactController = TextEditingController(text: storeData['storeAgentContact'] ?? '');
    final TextEditingController storeEmailController = TextEditingController(text: storeData['storeEmail'] ?? '');
    final TextEditingController storeTimingController = TextEditingController(text: storeData['storeTiming'] ?? '');
    final TextEditingController storeImageUrlController = TextEditingController(text: storeData['storeImageUrl'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Store'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Store Name (disabled if you don't want to allow editing)
                TextFormField(
                  controller: storeNameController,
                  decoration: const InputDecoration(labelText: 'Store Name'),
                  enabled: false, // Disable if storeName is the document ID
                  // If you want to allow editing storeName, handle document ID changes accordingly
                ),
                TextFormField(
                  controller: storeURLController,
                  decoration: const InputDecoration(labelText: 'Store URL'),
                ),
                TextFormField(
                  controller: storeDescriptionController,
                  decoration: const InputDecoration(labelText: 'Store Description'),
                ),
                TextFormField(
                  controller: storeRatingController,
                  decoration: const InputDecoration(labelText: 'Store Rating'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextFormField(
                  controller: storeTotalOrdersController,
                  decoration: const InputDecoration(labelText: 'Total Orders'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: storeAddressController,
                  decoration: const InputDecoration(labelText: 'Store Address'),
                ),
                TextFormField(
                  controller: storeAgentContactController,
                  decoration: const InputDecoration(labelText: 'Agent Contact'),
                ),
                TextFormField(
                  controller: storeEmailController,
                  decoration: const InputDecoration(labelText: 'Store Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: storeTimingController,
                  decoration: const InputDecoration(labelText: 'Store Timing'),
                ),
                TextFormField(
                  controller: storeImageUrlController,
                  decoration: const InputDecoration(labelText: 'Store Image URL'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Gather updated data
                Map<String, dynamic> updatedData = {
                  'storeURL': storeURLController.text.trim(),
                  'storeDescription': storeDescriptionController.text.trim(),
                  'storeRating': double.tryParse(storeRatingController.text.trim()) ?? 0.0,
                  'storeTotalOrders': int.tryParse(storeTotalOrdersController.text.trim()) ?? 0,
                  'storeAddress': storeAddressController.text.trim(),
                  'storeAgentContact': storeAgentContactController.text.trim(),
                  'storeEmail': storeEmailController.text.trim(),
                  'storeTiming': storeTimingController.text.trim(),
                  'storeImageUrl': storeImageUrlController.text.trim(),
                  // Add other fields as necessary
                };

                try {
                  await FirebaseFirestore.instance
                      .collection('admin_stores')
                      .doc(storeName)
                      .update(updatedData);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Store updated successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.pop(context); // Close the dialog
                } catch (e) {
                  print('Error updating store: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating store: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Function to show options on long press
  void _showOptions(BuildContext context, String storeName, Map<String, dynamic> storeData) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _editStore(context, storeName, storeData);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
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
                          _deleteStore(context, storeName);
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
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the list of stores
  Widget _buildStoreList(BuildContext context) {
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
                _showOptions(context, storeName, store);
              },
              child: Card(
                elevation: 3,
                margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ExpansionTile(
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
                  subtitle: storeURL != null
                      ? Text(
                    storeURL,
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  )
                      : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (storeDescription != null)
                            Text(
                              'Description: $storeDescription',
                              style: GoogleFonts.figtree(
                                fontSize: 14,
                                color: Colors.black,
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match the profile screen's background
      appBar: AppBar(
        title: Text(
          'All Stores',
          style: GoogleFonts.figtree(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEE764D), // Consistent AppBar color
        elevation: 0,
        actions: [
          // You can add additional actions here if needed
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildStoreList(context),
    );
  }
}
