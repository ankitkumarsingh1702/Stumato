// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hushh_for_students_ios/auth/authviewmodel.dart';
import 'package:hushh_for_students_ios/firebase_options.dart';
import 'package:hushh_for_students_ios/home.dart';
import 'package:hushh_for_students_ios/onboarding/onBoardingScreen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Authviewmodel(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: InitializerWidget(),
      routes: {
        '/home': (context) => MainScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

class InitializerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<Authviewmodel>(context, listen: false);

    return FutureBuilder(
      future: authViewModel.checkAuthentication(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/home');
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/onboarding');
            });
          }
          // Return an empty scaffold while the navigation occurs
          return Scaffold();
        } else if (snapshot.hasError) {
          // Handle any errors during the check
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          // Handle any other states
          return Scaffold(
            body: Center(child: Text('Something went wrong')),
          );
        }
      },
    );
  }
}
