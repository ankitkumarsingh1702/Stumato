import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hushh_for_students_ios/MiniStore/hfsministore.dart';
import 'package:hushh_for_students_ios/MainAct/DataStoreUrl.dart';
import 'package:app_tutorial/app_tutorial.dart';

class WebAct extends StatelessWidget {
  const WebAct({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference versionUpdateRef = firestore.collection('version_update_ios').doc('versionCodehfs');

    versionUpdateRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        String firestoreVersionCode = snapshot.get('versionCode') ?? '';
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
        _showFlushBar(context, 'Update link document does not exist.');
      }
    }).catchError((error) {
      _showFlushBar(context, 'Failed to retrieve update link: $error');
    });
  }

  Future<void> _openUpdateLink(String? link) async {
    if (link != null && link.isNotEmpty) {
      _showFlushBar(context, 'Opening update link: $link');
      if (await canLaunch(link)) {
        await launch(link);
      } else {
        _showFlushBar(context, 'Could not launch $link');
      }
    } else {
      _showFlushBar(context, 'Update link is empty or null.');
    }
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
                    'Quizizz', // new title
                  ];

                  List<String> subtitles = [
                    'Cafeteria, Culinary and Food',
                    'Cafeteria, Culinary and Food',
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
  final DataStoreUrl dataStoreUrl;

  const ProductCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.dataStoreUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
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
          Positioned(
            bottom: 10,
            left: 8,
            right: 8,
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
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                ElevatedButton(
                  onPressed: () async {
                    String storeUrl = await dataStoreUrl.getStoreUrl(
                        title.toLowerCase().contains('oac')
                            ? 'OAC'
                            : title.toLowerCase().contains('thapa')
                            ? 'Thapa'
                            : 'quizizz' // Exact store name for "Quizizz"
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HfsMiniStoreScreen(
                          storeName: title,
                          url: storeUrl,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(title.toLowerCase().contains('quizizz') ? 'Play Now' : 'Buy Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}