import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hushh_for_students_ios/MiniStore/hfsministore.dart';

class WebAct extends StatelessWidget {
  const WebAct({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hushh for Students',
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkVersionAndUpdate();
  }

  Future<void> _checkVersionAndUpdate() async {
    // Your version check code remains unchanged
  }

  Future<void> _retrieveUpdateLink() async {
    // Your update link retrieval code remains unchanged
  }

  Future<void> _openUpdateLink(String? link) async {
    // Your URL launcher code remains unchanged
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/app_bg.jpeg', // Your background image asset
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Text(
                    'Hushh for Students',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Products',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE8EAEC),
                        ),
                      ),
                      Text(
                        'Add new',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE74C5E),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 2 / 2.5,
                    ),
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      // Define the images and titles for each card
                      List<String> images = [
                        'lib/assets/oac.jpg',
                        'lib/assets/thapa.jpg',
                      ];

                      List<String> titles = [
                        'OAC Canteen',
                        'Thapa Mess',
                      ];

                      List<String> subtitles = [
                        'Cafeteria, Culinary and Food',
                        'Cafeteria, Culinary and Food',
                      ];

                      return ProductCard(
                        imagePath: images[index],
                        title: titles[index],
                        subtitle: subtitles[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const ProductCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay with less opacity at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.6), // Darkish overlay with opacity
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bright text for title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Bright text color
                    ),
                  ),
                  // Bright text for subtitle
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70, // Slightly less bright than title
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  // Button with lighter background color
                  ElevatedButton(
                    onPressed: () {
                      if (title.toLowerCase().contains('oac')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HfsMiniStoreScreen(
                                storeName: 'OAC',
                                url:
                                    'https://hushh-for-students-store-vone.mini.site'),
                          ),
                        );
                      } else if (title.toLowerCase().contains('thapa')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HfsMiniStoreScreen(
                                storeName: 'Thapa',
                                url: 'https://hushh-for-students.mini.store'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200], // Light button color
                      foregroundColor: Colors.black, // Dark text for contrast
                      minimumSize: const Size(100, 30), // Adjust button size
                    ),
                    child: Center(child: Text('Buy Now')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
