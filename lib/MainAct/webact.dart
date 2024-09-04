import 'package:flutter/material.dart';
import 'package:hushh_for_students/MiniStore/hfsministore.dart'; // Import the hfsministore.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E), // Background color to match your design
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Text(
                'Hushh for Students',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                padding: EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2 / 2.5,
                ),
                itemCount: 4, // Number of items
                itemBuilder: (context, index) {
                  // Define the images to be displayed
                  List<String> images = [
                    'lib/assets/oac.jpg',
                    'lib/assets/thapa.jpg',
                    'lib/assets/oac.jpg',
                    'lib/assets/thapa.jpg',
                  ];

                  // Define the titles and subtitles for each card
                  List<String> titles = [
                    'OAC Canteen',
                    'Thapa Mess',
                    'OAC Canteen',
                    'Thapa Mess',
                  ];

                  List<String> subtitles = [
                    'Cafeteria, Culinary and Food',
                    'Cafeteria, Culinary and Food',
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
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  ProductCard({required this.imagePath, required this.title, required this.subtitle, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8.0,
            left: 8.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HfsMiniStoreScreen(storeName: title),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: Text('Buy Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
