import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'authUserDetailsScreen.dart'; // Import the user details screen

class GoogleAuthScreen extends StatefulWidget {
  const GoogleAuthScreen({super.key});

  @override
  State<GoogleAuthScreen> createState() => _GoogleAuthScreenState();
}

class _GoogleAuthScreenState extends State<GoogleAuthScreen> {
  bool _isSigningIn = false; // Track the signing-in state

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double widthFactor = 0.85;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/app_bg.jpeg', // Background image
              fit: BoxFit.cover, // Ensures the image covers the whole screen
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Image.asset(
                    'lib/assets/aitlogoo.png', // Replace with your logo asset
                    width: 88,
                    height: 106,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'W E L C O M E  T O',
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
                    'Next-gen App, shaping our campus!',
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
                      children: [],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Sign in with Google',
                    style: GoogleFonts.figtree(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffe9ebee),
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: size.width * widthFactor,
                    child: CustomGradientButton(
                      text: 'Continue with Google',
                      onPressed: _isSigningIn
                          ? null
                          : () async {
                        setState(() {
                          _isSigningIn = true;
                        });
                        try {
                          // Initiating Google Sign-In
                          final userCredential = await signInWithGoogle(context);
                          if (userCredential != null) {
                            final user = userCredential.user;
                            final userName = user?.displayName ?? 'User';
                            final userId = user?.uid ?? 'Unknown ID';

                            // Displaying Snackbar with user name and ID
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Welcome, $userName! Step into the future with Stumato',
                                  style: GoogleFonts.figtree(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
                              ),
                            );

                            if (kDebugMode) {
                              print("User Signed In: $userName, ID: $userId");
                            }

                            // Show the loader before navigation
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            // Simulate a delay for the loader (e.g., 2 seconds)
                            await Future.delayed(const Duration(seconds: 2));

                            // Navigate to AuthUserDetailsScreen
                            Navigator.pop(context); // Remove the loader
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthUserDetailsScreen(user: user),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sign-in process returned null.')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                          if (kDebugMode) {
                            print('Sign-in error: $e');
                          }
                        } finally {
                          setState(() {
                            _isSigningIn = false;
                          });
                        }
                      },
                    ),
                  ),
                  if (_isSigningIn)
                    const SizedBox(height: 20),
                  if (_isSigningIn)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to handle Google Sign-In with proper logging
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      if (kDebugMode) {
        print("Starting Google Sign-In process...");
      }

      // Initialize GoogleSignIn with scopes if needed
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          // Add any other scopes you need
        ],
      );

      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Check if user canceled the sign-in
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in canceled')),
        );
        if (kDebugMode) {
          print('Google Sign-In canceled by the user.');
        }
        return null;
      }

      if (kDebugMode) {
        print('Google User Account: ${googleUser.email}');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Check if accessToken and idToken are received
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to obtain authentication tokens.')),
        );
        if (kDebugMode) {
          print('GoogleAuth tokens are null.');
        }
        return null;
      }

      // Create a credential using GoogleAuthProvider
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Log credential creation
      if (kDebugMode) {
        print('Google Sign-In: AccessToken: ${googleAuth.accessToken}');
        print('Google Sign-In: IDToken: ${googleAuth.idToken}');
      }

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (kDebugMode) {
        print('Firebase User: ${userCredential.user?.displayName}');
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Error during Google Sign-In: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
      return null;
    }
  }
}

// Custom Gradient Button without icon
class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}
