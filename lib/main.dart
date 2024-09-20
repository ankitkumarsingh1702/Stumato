import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:hushh_for_students/MiniStore/hfsministore.dart'; // Import the hfsministore.dart file
=======
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:hushh_for_students/MainAct/webact.dart';  // Correct path for webact.dart
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets are initialized
  await Firebase.initializeApp(); // Initialize Firebase

<<<<<<< HEAD
  runApp(const WebAct());
}

class WebAct extends StatelessWidget {
  const WebAct({super.key});
=======
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'Hushh for Students',
      home: const HomeScreen(),
=======
      title: 'Hushh for Students', // hfs
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WebAct(),
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
      debugShowCheckedModeBanner: false, // This removes the debug banner
    );
  }
}
<<<<<<< HEAD

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkVersionAndUpdate();  // Add the Firebase version check
  }

  Future<void> _checkVersionAndUpdate() async {
    // Get the installed version of the app
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String installedVersion = packageInfo.buildNumber;
    Fluttertoast.showToast(
      msg: 'Installed Version Code: $installedVersion',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Fetch the version code from Firestore
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference versionUpdateRef = firestore.collection('version_update_ios').doc('versionCodehfs');

    versionUpdateRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        String firestoreVersionCode = snapshot.get('versionCode') ?? '';
        Fluttertoast.showToast(
          msg: 'Firestore Version Code Retrieved: $firestoreVersionCode',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        if (firestoreVersionCode != installedVersion) {
          Fluttertoast.showToast(
            msg: 'Version mismatch: Updating app...',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          _retrieveUpdateLink();
        } else {
          Fluttertoast.showToast(
            msg: 'App is up-to-date.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'No version info found in Firestore.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }, onError: (error) {
      Fluttertoast.showToast(
        msg: 'Error fetching Firestore version: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  Future<void> _retrieveUpdateLink() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference updateLinkRef = firestore.collection('version_update_ios').doc('apkupdatedlink');

    updateLinkRef.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        String? updateLink = documentSnapshot.get('link');
        _openUpdateLink(updateLink);
      } else {
        Fluttertoast.showToast(
          msg: 'Update link document does not exist.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: 'Failed to retrieve update link: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  Future<void> _openUpdateLink(String? link) async {
    if (link != null && link.isNotEmpty) {
      Fluttertoast.showToast(
        msg: 'Opening update link: $link',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      if (await canLaunch(link)) {
        await launch(link);
      } else {
        Fluttertoast.showToast(
          msg: 'Could not launch $link',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Update link is empty or null.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // Background color to match your design
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

  const ProductCard({required this.imagePath, required this.title, required this.subtitle, Key? key}) : super(key: key);

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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
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
                  child: const Text('Buy Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
=======
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
