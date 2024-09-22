import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'AdminLoginScreen.dart';
import 'NewsDetailScreen.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  // Search query
  String _searchQuery = '';

  // TextEditingController for search
  final TextEditingController _searchController = TextEditingController();

  // Function to navigate to NewsDetailScreen with announcement data
  void _navigateToDetail(BuildContext context, Map<String, dynamic> announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(announcement: announcement),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to filter announcements based on search query
  bool _filterAnnouncement(Map<String, dynamic> announcement) {
    if (_searchQuery.isEmpty) {
      return true;
    }
    String heading = announcement['heading']?.toString().toLowerCase() ?? '';
    String content = announcement['content']?.toString().toLowerCase() ?? '';
    String query = _searchQuery.toLowerCase();

    return heading.contains(query) || content.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Announcements', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFEE764D),
        actions: [
          IconButton(
            onPressed: () {
              // Implement grid view functionality if needed
              // For example, navigate to a grid view screen
            },
            icon: const Icon(Icons.grid_view, color: Colors.white),
            tooltip: 'Grid View',
          ),
        ],
        // Make the icons and text white
        iconTheme: const IconThemeData(color: Colors.white),
        // Remove shadow
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Announcements',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
          // Announcements List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('announcements')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Error Handling
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error fetching announcements: ${snapshot.error}',
                      style: GoogleFonts.figtree(fontSize: 16, color: Colors.red),
                    ),
                  );
                }

                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Data Retrieved
                final announcements = snapshot.data!.docs;

                // Filter announcements based on search query
                final filteredAnnouncements = announcements
                    .where((doc) => _filterAnnouncement(doc.data() as Map<String, dynamic>))
                    .toList();

                if (filteredAnnouncements.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No announcements available.'
                          : 'No announcements match your search.',
                      style: GoogleFonts.figtree(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredAnnouncements.length,
                  itemBuilder: (context, index) {
                    var announcement = filteredAnnouncements[index].data() as Map<String, dynamic>;
                    String heading = announcement['heading'] ?? 'No Heading';
                    String? content = announcement['content'];
                    String? imageUrl = announcement['imageUrl'];
                    String? dataUrl = announcement['dataUrl'];
                    String publishedBy = announcement['publishedBy'] ?? 'Unknown';
                    Timestamp? createdAt = announcement['createdAt'];

                    DateTime? createdDate = createdAt != null ? createdAt.toDate() : null;

                    return ListTile(
                      onTap: () => _navigateToDetail(context, announcement),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: imageUrl != null
                              ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                              : const DecorationImage(
                            image: AssetImage('assets/default_announcement.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        heading,
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (content != null && content.isNotEmpty)
                            Text(
                              content.length > 50 ? '${content.substring(0, 50)}...' : content,
                              style: GoogleFonts.figtree(fontSize: 14, color: Colors.grey[700]),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Published by: $publishedBy',
                            style: GoogleFonts.figtree(fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (createdDate != null)
                            Text(
                              'Created at: ${createdDate.toLocal()}',
                              style: GoogleFonts.figtree(fontSize: 12, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEE764D),
        onPressed: () {
          // Navigate to AddAnnouncement screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Announcement',
      ),
    );
  }
}
