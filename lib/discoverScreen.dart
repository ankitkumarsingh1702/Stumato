import 'package:flutter/material.dart';

class Discoverscreen extends StatefulWidget {
  const Discoverscreen({super.key});

  @override
  State<Discoverscreen> createState() => _DiscoverscreenState();
}

class _DiscoverscreenState extends State<Discoverscreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'lib/assets/app_bg.jpeg', // Replace with your image path
            fit: BoxFit.cover, // Ensures the image covers the entire background
          ),
        ),
        // Gradient Overlay
        Positioned.fill(
          child: Container(),
        ),
        // Centered Text
        Center(
          child: Text(
            'Under Development',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
