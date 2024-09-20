import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushh_for_students_ios/auth/authviewmodel.dart';
import 'package:hushh_for_students_ios/components/customButton.dart';
import 'package:hushh_for_students_ios/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';

class GoogleAuthScreen extends StatefulWidget {
  const GoogleAuthScreen({super.key});

  @override
  State<GoogleAuthScreen> createState() => _GoogleAuthScreenState();
}

class _GoogleAuthScreenState extends State<GoogleAuthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Authviewmodel>(context, listen: false)
          .checkAuthentication(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double widthFactor = 0.85;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/app_bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add the progress bar at the top
                  const GradientProgressBar(
                    progress: 0.6, // Adjust the progress value as needed
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),
                  Text(
                    'Sign in with Google',
                    style: GoogleFonts.figtree(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffe9ebee),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Make Button responsive for Google Sign-In
                  Consumer<Authviewmodel>(
                    builder: (context, authViewModel, _) {
                      return Column(
                        children: [
                          SizedBox(
                            width: size.width * widthFactor,
                            child: IAgreeButton(
                              text: authViewModel.isLoading
                                  ? 'Signing In...'
                                  : 'Continue with Google',
                              onPressed: authViewModel.isLoading
                                  ? () {} // Provide an empty callback to avoid type errors
                                  : () {
                                      authViewModel.signInWithGoogle(context);
                                    },
                              size: size.width * widthFactor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (authViewModel.isLoading)
                            const CircularProgressIndicator(),
                        ],
                      );
                    },
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
