import 'dart:async'; // Added for StreamSubscription
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'Announcement.dart';
import 'Coupon.dart';
import 'profilescreen.dart';
import 'AdminLoginScreen.dart';
import '../Auth/UserOnboardingScreenFirst.dart';
import 'package:hushh_for_students_ios/MiniStore/hfsministore.dart'; // Ensure correct path
// import 'package:hushh_for_students_ios/MainAct/DataStoreUrl.dart'; // Ensure correct path

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // final DataStoreUrl dataStoreUrl = DataStoreUrl(); // Assuming this class is defined elsewhere

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocumentSubscription;

  @override
  void initState() {
    super.initState();
    _checkVersionAndUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUserUidSnackbar();
      _listenToUserDocument();
    });
  }

  @override
  void dispose() {
    _userDocumentSubscription?.cancel();
    super.dispose();
  }

  /// Listens to user document changes and navigates accordingly
  void _listenToUserDocument() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No user is signed in, navigate to Onboarding
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserOnboardingScreenFirst()),
            (route) => false,
      );
      return;
    }

    _userDocumentSubscription = FirebaseFirestore.instance
        .collection('user_stumato')
        .doc(user.uid)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (!mounted) return; // Check if widget is still mounted
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        if (data != null &&
            data.containsKey('first_name') &&
            data.containsKey('last_name') &&
            data.containsKey('phone_number') &&
            data.containsKey('email') &&
            data.containsKey('birthday') &&
            data.containsKey('profile_pic_url') &&
            data.containsKey('created_at')) {
          // All required fields are present, stay on MainAppScreen
          // Maybe do nothing
        } else {
          // If document doesn't exist or fields are missing, navigate to Onboarding
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const UserOnboardingScreenFirst()),
                (route) => false,
          );
        }
      } else {
        // If document doesn't exist, navigate to Onboarding
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserOnboardingScreenFirst()),
              (route) => false,
        );
      }
    });
  }

  /// Checks the app version against Firestore and prompts update if needed
  Future<void> _checkVersionAndUpdate() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String installedVersion = packageInfo.buildNumber;

      _showFlushBar(context, 'Installed Version Code: $installedVersion');

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentReference versionUpdateRef =
      firestore.collection('version_update_ios').doc('versionCodehfs');

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
    } catch (e) {
      _showFlushBar(context, 'Error checking version: $e');
    }
  }

  /// Retrieves the update link from Firestore and opens it
  Future<void> _retrieveUpdateLink() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentReference updateLinkRef =
      firestore.collection('version_update_ios').doc('apkupdatedlink');

      DocumentSnapshot documentSnapshot = await updateLinkRef.get();

      if (documentSnapshot.exists) {
        String? updateLink = documentSnapshot.get('link');
        _openUpdateLink(updateLink);
      } else {
        _showFlushBar(context, 'Update link document does not exist.');
      }
    } catch (e) {
      _showFlushBar(context, 'Failed to retrieve update link: $e');
    }
  }

  /// Opens the provided update link using url_launcher
  Future<void> _openUpdateLink(String? link) async {
    if (link != null && link.isNotEmpty) {
      _showFlushBar(context, 'Opening update link: $link');
      final Uri url = Uri.parse(link);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showFlushBar(context, 'Could not launch $link');
      }
    } else {
      _showFlushBar(context, 'Update link is empty or null.');
    }
  }

  /// Displays a Flushbar message with custom duration
  void _showCustomDurationFlushBar(
      BuildContext context, String message, Duration duration) {
    Flushbar(
      messageText: Row(
        children: [
          const Icon(Icons.info, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      duration: duration,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
    ).show(context);
  }

  /// Shortcut to show Flushbar with 1-second duration
  void _showFlushBar(BuildContext context, String message) {
    _showCustomDurationFlushBar(context, message, const Duration(seconds: 1));
  }

  /// Shows the user's UID in a SnackBar
  Future<void> _showUserUidSnackbar() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your UID: $uid'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user is currently signed in.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Retrieves the user's profile picture URL from Firestore
  Future<String?> _getProfilePicUrl() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('user_stumato').doc(user.uid).get();
      return userDoc['profile_pic_url'];
    }
    return null;
  }

  /// Builds the navigation drawer
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFEE764D),
            ),
            child: Text(
              'SmartEats \nby Stumato',
              style: GoogleFonts.figtree(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              'My Profile',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MyProfileScreen(user: FirebaseAuth.instance.currentUser),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_offer),
            title: Text(
              'Coupons',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CouponScreen(), // Placeholder for coupon.dart
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: Text(
              'Important Announcements',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementScreen(), // Placeholder for announcement.dart
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: Text(
              'Login as Admin',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminLoginScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              'Logout',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              await _logoutUser();
            },
          ),
        ],
      ),
    );
  }

  /// Handles user logout and account deletion
  Future<void> _logoutUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user is currently signed in.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('user_stumato').doc(user.uid).delete();
      await user.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted and logged out successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserOnboardingScreenFirst()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please re-authenticate to delete your account.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea( // Ensures UI does not overlap with system UI
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: Text(
            'SmartEats by Stumato',
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FutureBuilder<String?>(
                future: _getProfilePicUrl(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 18,
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyProfileScreen(user: FirebaseAuth.instance.currentUser),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        backgroundImage:
                        NetworkImage('https://via.placeholder.com/50'),
                        radius: 18,
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyProfileScreen(user: FirebaseAuth.instance.currentUser),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!),
                        radius: 18,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('admin_stores').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error fetching stores.'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final stores = snapshot.data?.docs ?? [];

            if (stores.isEmpty) {
              return const Center(
                child: Text('No stores available.'),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                // Removed padding from GridView and moved it to Padding widget
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.75, // Adjusted for better fit
                ),
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final store = stores[index].data() as Map<String, dynamic>;

                  String storeName = store['storeName'] ?? 'Unnamed Store';
                  String? storeImageUrl = store['storeImageUrl'];
                  String? storeURL = store['storeURL'];
                  String? storeDescription = store['storeDescription'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Prevents the Column from expanding
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded( // Makes the image take up available space
                          child: storeImageUrl != null
                              ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10)),
                            child: Image.network(
                              storeImageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          )
                              : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.store,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Prevents inner Column from expanding
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storeName,
                                style: GoogleFonts.figtree(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                storeDescription ?? 'No description available',
                                style: GoogleFonts.figtree(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity, // Makes the button stretch horizontally
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (storeURL != null && storeURL.isNotEmpty) {
                                      _visitStore(storeURL, storeName);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content:
                                          Text('Store URL is not available.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEE764D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    storeName.toLowerCase().contains('quizizz')
                                        ? 'Play Now'
                                        : 'Visit Now',
                                    style: GoogleFonts.figtree(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// Navigates to the HfsMiniStoreScreen with the provided URL and store name
  void _visitStore(String storeURL, String storeName) async {
    final Uri url = Uri.parse(storeURL);
    if (await canLaunchUrl(url)) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HfsMiniStoreScreen(
            storeName: storeName,
            url: storeURL,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $storeURL'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// ProductCard Widget representing each store
class ProductCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  // final DataStoreUrl dataStoreUrl;

  const ProductCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    // required this.dataStoreUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The main build logic is now handled in MainAppScreen's GridView.builder
    return Container(); // Placeholder as actual UI is built in GridView.builder
  }
}
