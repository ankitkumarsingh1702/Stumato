import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hushh_for_students_ios/MiniStore/hfsministore.dart';
import 'package:hushh_for_students_ios/MainAct/DataStoreUrl.dart';
import 'package:app_tutorial/app_tutorial.dart';

import 'package:hushh_for_students_ios/MiniStore/hfsministore.dart';

=======
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:hushh_for_students/MiniStore/hfsministore.dart'; // Import the hfsministore.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets are initialized
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(const WebAct());
}
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661

class WebAct extends StatelessWidget {
  const WebAct({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return const HomeScreen();
=======
    return MaterialApp(
      title: 'Hushh for Students',
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, // This removes the debug banner
    );
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD
  final DataStoreUrl dataStoreUrl = DataStoreUrl();
  GlobalKey _oacButtonKey = GlobalKey();
  late List<TutorialItem> tutorialItems;

  @override
  void initState() {
    super.initState();
    _checkVersionAndUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupTutorial();
      _startTutorial();
    });
  }

  Future<void> _checkVersionAndUpdate() async {

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String installedVersion = packageInfo.buildNumber;

    _showFlushBar(context, 'Installed Version Code: $installedVersion');

=======
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
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference versionUpdateRef = firestore.collection('version_update_ios').doc('versionCodehfs');

    versionUpdateRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        String firestoreVersionCode = snapshot.get('versionCode') ?? '';
<<<<<<< HEAD
        _showFlushBar(context, 'Firestore Version Code: $firestoreVersionCode');

        if (firestoreVersionCode != installedVersion) {
          _showFlushBar(context, 'Version mismatch: Updating app...');
          _retrieveUpdateLink();
        } else {
          debugPrint('App is up-to-date.');
        }
      } else {
        _showFlushBar(context, 'No version info found in Firestore.');
      }
    }, onError: (error) {
      _showFlushBar(context, 'Error fetching Firestore version: $error');
=======
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
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
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
<<<<<<< HEAD
        _showFlushBar(context, 'Update link document does not exist.');
      }
    }).catchError((error) {
      _showFlushBar(context, 'Failed to retrieve update link: $error');
=======
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
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
    });
  }

  Future<void> _openUpdateLink(String? link) async {
    if (link != null && link.isNotEmpty) {
<<<<<<< HEAD
      _showFlushBar(context, 'Opening update link: $link');
      if (await canLaunch(link)) {
        await launch(link);
      } else {
        _showFlushBar(context, 'Could not launch $link');
      }
    } else {
      _showFlushBar(context, 'Update link is empty or null.');
    }

    // Your version check code remains unchanged
  }

  Future<void> _retrieveUpdateLink() async {
    // Your update link retrieval code remains unchanged
  }

  Future<void> _openUpdateLink(String? link) async {
    // Your URL launcher code remains unchanged

  }

  void _setupTutorial() {
    tutorialItems = [
      TutorialItem(
        globalKey: _oacButtonKey,
        color: Colors.black.withOpacity(0.5),
        radius: 8.0,
        child: Positioned(
          bottom: -40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Click on Buy Now to place your order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _startTutorial() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _showCustomDurationFlushBar(context, 'Click on Buy Now to place your order', Duration(seconds: 8));
    });

    Tutorial.showTutorial(context, tutorialItems, onTutorialComplete: () {
      _showFlushBar(context, 'Tutorial complete!');
    });
  }

  void _showCustomDurationFlushBar(BuildContext context, String message, Duration duration) {
    Flushbar(
      messageText: Row(
        children: [
          Icon(Icons.info, color: Colors.black),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      duration: duration,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(8),
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
    ).show(context);
  }

  void _showLongFlushBar(BuildContext context) {
    _showCustomDurationFlushBar(context, 'Click on Buy Now to place your order', Duration(seconds: 2));
  }

  void _showFlushBar(BuildContext context, String message) {
    _showCustomDurationFlushBar(context, message, Duration(seconds: 1));
=======
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
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
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

                itemCount: 3, // updated to 3 to include the new card
                itemBuilder: (context, index) {
                  List<String> images = [
                    'lib/assets/oac.jpg',
                    'lib/assets/thapa.jpg',
                    'lib/assets/amzon_vc_quiz.jpg', // new image
                  ];

                  List<String> titles = [
                    'OAC Canteen',
                    'Thapa Mess',
                    'Hushh Quiz', // replaced title
=======
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
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
                  ];

                  List<String> subtitles = [
                    'Cafeteria, Culinary and Food',
                    'Cafeteria, Culinary and Food',
<<<<<<< HEAD
                    'Play quiz, win ₹100 voucher',
                  ];

                  return ProductCard(
                    key: index == 0 ? _oacButtonKey : null,
                    imagePath: images[index],
                    title: titles[index],
                    subtitle: subtitles[index],
                    dataStoreUrl: dataStoreUrl,
                  );
                },
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
=======
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
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
<<<<<<< HEAD
  final DataStoreUrl dataStoreUrl;

  const ProductCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,

    required this.dataStoreUrl,

    Key? key,
  }) : super(key: key);
=======

  const ProductCard({required this.imagePath, required this.title, required this.subtitle, Key? key}) : super(key: key);
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
<<<<<<< HEAD

          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 120, // Adjust height as needed
            width: double.infinity,
          ),

          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60, // 50% height for gradient
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
          // Dark overlay with less opacity at the bottom
          Positioned(

            bottom: 10,
            left: 8,
            right: 8,
=======
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8.0,
            left: 8.0,
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
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
<<<<<<< HEAD
                const SizedBox(height: 4.0),
=======
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                ElevatedButton(
<<<<<<< HEAD
                  onPressed: () async {
                    String storeUrl = await dataStoreUrl.getStoreUrl(
                        title.toLowerCase().contains('oac')
                            ? 'OAC'
                            : title.toLowerCase().contains('thapa')
                            ? 'Thapa'
                            : 'hushh_quiz' // updated store name
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HfsMiniStoreScreen(
                          storeName: title,
                          url: storeUrl,
                        ),
=======
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HfsMiniStoreScreen(storeName: title),
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Padding for button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners for button
                    ),
                    elevation: 10, // Shadow effect for a 3D feel
                    shadowColor: Colors.black.withOpacity(0.3), // Shadow color
                    backgroundColor: Colors.transparent, // To apply gradient
                  ).copyWith(
                    foregroundColor: MaterialStateProperty.all(Colors.white), // Text color
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.black], // White and Black gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12), // Same rounded corners as the button
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        title.toLowerCase().contains('hushh_quiz') ? 'Play Now' : 'Buy Now',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

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

=======
                    backgroundColor: Colors.black, // Background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: const Text('Buy Now'),
                ),
              ],
>>>>>>> 84ab20b10485b155bd0724e12a758ef94078a661
            ),
          ),
        ],
      ),
    );
  }
}
