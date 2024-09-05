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
    // Fetch the installed version
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String installedVersion = packageInfo.buildNumber;
    Fluttertoast.showToast(
      msg: 'Installed Version Code: $installedVersion',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Retrieve the version code from Firestore
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference versionUpdateRef =
        firestore.collection('version_update_ios').doc('versionCodehfs');

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
    final DocumentReference updateLinkRef =
        firestore.collection('version_update_ios').doc('apkupdatedlink');

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
      backgroundColor: const Color(0xFF1C1C1E),
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
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const ProductCard(
      {required this.imagePath,
      required this.title,
      required this.subtitle,
      Key? key})
      : super(key: key);

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
                    // Navigate based on store title
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
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
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
