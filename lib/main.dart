import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hushh_for_students_ios/MainAct/webact.dart';
import 'package:app_tutorial/app_tutorial.dart'; // Import app_tutorial

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hushh for Students',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WebAct(),
      debugShowCheckedModeBanner: false,
    );
  }
}