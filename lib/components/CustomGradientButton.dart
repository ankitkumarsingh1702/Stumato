import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomGradientButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  const CustomGradientButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Proper padding for icon and text
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.0),
        ),
      ),
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            stops: [0.00, 1.00],
            colors: [
              Color(0xFFE54D60), // Start color
              Color(0xFFA342FF), // End color
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.all(Radius.circular(22.0)),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 342.0,
            minHeight: 44.0,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min, // To make sure content stays centered
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 10), // Spacing between icon and text
              Text(
                text,
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
