// NewsDetailScreen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const NewsDetailScreen({Key? key, required this.announcement}) : super(key: key);

  // Function to open URL
  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the file.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    String heading = announcement['heading'] ?? 'No Heading';
    String? content = announcement['content'];
    String? imageUrl = announcement['imageUrl'];
    String? dataUrl = announcement['dataUrl'];
    String category = announcement['category'] ?? 'General';
    String publishedBy = announcement['publishedBy'] ?? 'Unknown';
    Timestamp? createdAt = announcement['createdAt'];

    DateTime? createdDate = createdAt != null ? createdAt.toDate() : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Announcement Details',
          style: GoogleFonts.figtree(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFEE764D),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              // Implement share functionality if needed
              // For example, share the announcement link
            },
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share Announcement',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Announcement Image
              if (imageUrl != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: const DecorationImage(
                      image: AssetImage('assets/default_announcement.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Category Chips
              Row(
                children: [
                  Chip(
                    label: Text(
                      category,
                      style: GoogleFonts.figtree(color: Colors.white),
                    ),
                    backgroundColor: Colors.purple.shade400,
                  ),
                  const SizedBox(width: 8),
                  // Add more chips if needed
                ],
              ),
              const SizedBox(height: 16),
              // Heading
              Text(
                heading,
                style: GoogleFonts.figtree(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              // Author and Time
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/sample_avatar.png'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    publishedBy,
                    style: GoogleFonts.figtree(fontSize: 16, color: Colors.black87),
                  ),
                  const Spacer(),
                  Text(
                    createdDate != null
                        ? '${createdDate.toLocal()}'.split('.')[0]
                        : 'Unknown',
                    style: GoogleFonts.figtree(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Content
              if (content != null && content.isNotEmpty)
                Text(
                  content,
                  style: GoogleFonts.figtree(fontSize: 16, color: Colors.black87),
                ),
              const SizedBox(height: 16),
              // Attached File
              if (dataUrl != null)
                GestureDetector(
                  onTap: () {
                    _launchURL(context, dataUrl);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Attached File',
                        style: GoogleFonts.figtree(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Optionally, add more details or actions
            ],
          ),
        ),
      ),
    );
  }
}
