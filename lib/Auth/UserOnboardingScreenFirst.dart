import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'googleAuthScreen.dart';
import 'package:hushh_for_students_ios/Auth/UserOnboardingScreenFirst.dart'; // Ensure correct import

class UserOnboardingScreenFirst extends StatefulWidget {
  const UserOnboardingScreenFirst({super.key});

  @override
  State<UserOnboardingScreenFirst> createState() =>
      _UserOnboardingScreenFirstState();
}

class _UserOnboardingScreenFirstState
    extends State<UserOnboardingScreenFirst> {
  bool isChecked = true; // Default checked

  // Function to launch the privacy policy link
  Future<void> _launchPrivacyPolicyUrl() async {
    final Uri url = Uri.parse(
        'https://www.canva.com/design/DAGRS-kdgm0/NLRE2bKvsUZrfLNWsOg-4g/view?utm_content=DAGRS-kdgm0&utm_campaign=designshare&utm_medium=link&utm_source=editor');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/app_bg.jpeg'), // Background image
            fit: BoxFit.cover, // Ensures the image covers the whole screen
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 92.0, bottom: 20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/aitlogoo.png', // Logo image
                    width: 88,
                    height: 106.34,
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'W E L C O M E   T O',
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xffe54d60),
                              Color(0xffa342ff)
                            ],
                            tileMode: TileMode.mirror,
                          ).createShader(bounds),
                          child: Text(
                            'stumato',
                            style: GoogleFonts.figtree(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Next-gen App, shaping our campus!',
                          style: GoogleFonts.figtree(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const RulesSection(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Terms and Privacy Checkbox
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isChecked = newValue!;
                            });
                          },
                          checkColor: Colors.white,
                          activeColor: Colors.transparent, // To match design
                          side: const BorderSide(color: Colors.white), // Border color
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _launchPrivacyPolicyUrl,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Privacy, Terms & Conditions',
                                    style: GoogleFonts.figtree(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.link,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // "I Agree" button
                  IAgreeButton(
                    text: 'I Agree',
                    onPressed: isChecked
                        ? () {
                      navigateToNextScreen(context);
                    }
                        : null,
                    size: 127.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateToNextScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoogleAuthScreen()),
    );
  }
}

// Extracted RulesSection for better readability and performance
class RulesSection extends StatelessWidget {
  const RulesSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        RulesBox(
          textElemnt1: 'Enhanced Dining Experience',
          textElement2:
          'Enjoy a seamless dining experience with AI-powered recommendations and easy ordering.',
        ),
        RulesBox(
          textElemnt1: 'Next-Gen Store',
          textElement2:
          'Get access to the next generation of campus stores, providing fast and convenient service.',
        ),
        RulesBox(
          textElemnt1: 'User-Friendly Navigation',
          textElement2:
          'Navigate easily through the app to browse menus, place orders, and track your meal.',
        ),
      ],
    );
  }
}

// RulesBox widget implementing the design for headings and content
class RulesBox extends StatelessWidget {
  final String textElemnt1;
  final String textElement2;

  const RulesBox({
    Key? key,
    required this.textElemnt1,
    required this.textElement2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textElemnt1,
            style: GoogleFonts.figtree(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            textElement2,
            style: GoogleFonts.figtree(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFB7B7B7),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom 'I Agree' button with gradient and corner radius as per design
class IAgreeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double size;

  const IAgreeButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center( // Centering the button
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: size, vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.0),
          ),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE54D60), Color(0xFFA342FF)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.all(Radius.circular(22.0)),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 127.0,
              minHeight: 44.0,
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
