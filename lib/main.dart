import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:hushh_for_students/MainAct/webact.dart';  // Correct path for webact.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets are initialized
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hushh for Students', // Changed app name here
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WebAct(),  // Set WebAct as the home screen
      debugShowCheckedModeBanner: false, // This removes the debug banner
    );
  }
}
