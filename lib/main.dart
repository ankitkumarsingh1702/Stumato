import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_analytics/firebase_analytics.dart'; // Firebase Analytics
import 'package:firebase_analytics/observer.dart'; // Firebase Analytics Observer
import 'package:url_launcher/url_launcher.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'Auth/GoogleAuthScreen.dart';
import 'Auth/UserOnboardingScreenFirst.dart';
import 'HomeScreens/home.dart'; // Import HomeScreen
import 'MiniStore/hfsministore.dart';
// import 'MainAct/DataStoreUrl.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Firebase Analytics instance and observer
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hushh for Students',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.figtreeTextTheme(), // Apply Google Fonts globally
      ),
      home: const LandingPage(), // Start with LandingPage
      navigatorObservers: [observer], // Add the Analytics Observer
      debugShowCheckedModeBanner: false,
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // State variables to track loading and navigation
  bool _isLoading = true;
  Widget _currentScreen = const SizedBox(); // Placeholder

  // Subscription for Firestore snapshot listener
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _userDocSubscription;

  @override
  void initState() {
    super.initState();
    _logScreenView('LandingPage'); // Log LandingPage view
    _determineStartScreen();
  }

  @override
  void dispose() {
    // Cancel the Firestore subscription when the widget is disposed
    _userDocSubscription.cancel();
    super.dispose();
  }

  // Function to log screen views
  void _logScreenView(String screenName) {
    FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  void _determineStartScreen() {
    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // No user is signed in, navigate to Onboarding
        setState(() {
          _logScreenView('UserOnboardingScreenFirst'); // Log Onboarding screen
          _currentScreen = const UserOnboardingScreenFirst();
          _isLoading = false;
        });
        // Cancel any existing Firestore subscriptions
        _userDocSubscription.cancel();
      } else {
        // User is signed in, set up Firestore listener for user document
        _userDocSubscription = FirebaseFirestore.instance
            .collection('user_stumato')
            .doc(user.uid)
            .snapshots()
            .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
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
              // All required fields are present, navigate to Home
              setState(() {
                _logScreenView('MainAppScreen'); // Log Home screen
                _currentScreen = const MainAppScreen();
                _isLoading = false;
              });
            } else {
              // If document fields are missing, navigate to Onboarding
              setState(() {
                _logScreenView('UserOnboardingScreenFirst'); // Log Onboarding screen
                _currentScreen = const UserOnboardingScreenFirst();
                _isLoading = false;
              });
            }
          } else {
            // If document doesn't exist, navigate to Onboarding
            setState(() {
              _logScreenView('UserOnboardingScreenFirst'); // Log Onboarding screen
              _currentScreen = const UserOnboardingScreenFirst();
              _isLoading = false;
            });
          }
        }, onError: (error) {
          // Handle errors, possibly navigate to Onboarding
          setState(() {
            _logScreenView('UserOnboardingScreenFirst'); // Log Onboarding screen
            _currentScreen = const UserOnboardingScreenFirst();
            _isLoading = false;
          });
          print('Error listening to user document: $error');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator while determining the start screen
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    // Once loading is complete, display the appropriate screen
    return _currentScreen;
  }
}
