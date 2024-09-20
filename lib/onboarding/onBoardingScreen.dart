import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushh_for_students_ios/auth/authnameScreen.dart';
import 'package:hushh_for_students_ios/components/customButton.dart';
import 'package:hushh_for_students_ios/onboarding/components/rulesTextBox.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void navigateToNextScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthNameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/assets/aitlogoo.png',
                    width: 88,
                    height: 106.34,
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            colors: [Color(0xffe54d60), Color(0xffa342ff)],
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
                          'Please follow these house rules',
                          style: GoogleFonts.figtree(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              RulesBox(
                                textElemnt1: 'Secured Payments',
                                textElement2:
                                    'Ensure all transactions are protected with industry-standard encryption, offering users a safe and secure payment experience',
                              ),
                              RulesBox(
                                textElemnt1: 'Data Safety & Privacy',
                                textElement2:
                                    'User data is stored securely, adhering to the latest privacy regulations, and ensuring no unauthorized access to personal information.',
                              ),
                              RulesBox(
                                textElemnt1: 'Ease of Access',
                                textElement2:
                                    'Intuitive user interface with easy navigation, ensuring that users can browse, order, and pay for their meals effortlessly, catering to all levels of tech-savviness.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  IAgreeButton(
                    text: 'I Agree',
                    onPressed: () {
                      navigateToNextScreen(context);
                    },
                    size: 127.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
