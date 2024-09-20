import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushh_for_students_ios/auth/authphonescreen.dart';
import 'package:hushh_for_students_ios/auth/authviewmodel.dart';
import 'package:hushh_for_students_ios/components/customButton.dart';
import 'package:hushh_for_students_ios/components/customTextBox.dart';
import 'package:hushh_for_students_ios/onboarding/components/customProgressIndicator.dart';
import 'package:provider/provider.dart';

class AuthNameScreen extends StatefulWidget {
  const AuthNameScreen({super.key});

  @override
  State<AuthNameScreen> createState() => _AuthNameScreenState();
}

class _AuthNameScreenState extends State<AuthNameScreen> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  String? _errorText; // Track the error message

  void _validateAndProceed() {
    final firstName = _firstName.text;
    final lastName = _lastName.text;

    if (firstName.isEmpty) {
      setState(() {
        _errorText = 'Name cannot be empty';
      });
    } else {
      final viewModel = Provider.of<Authviewmodel>(context, listen: false);
      viewModel.updateFirstName(firstName);
      viewModel.updateLastName(lastName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthPhoneScreen(),
        ),
      );
      setState(() {
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double widthFactor = 0.85;

    return Scaffold(
      body: Stack(
        children: [
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
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: size.height * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GradientProgressBar(
                    progress: 0.1,
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),
                  Text(
                    'My Name is',
                    style: GoogleFonts.figtree(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffe9ebee),
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: size.width * widthFactor,
                    child: Customtextbox(
                      controller: _firstName,
                      hint: 'Enter your first name',
                      errorText: _errorText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: size.width * widthFactor,
                    child: Customtextbox(
                      controller: _lastName,
                      hint: 'Enter your last name',
                      errorText: _errorText,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: size.width * widthFactor,
                    child: IAgreeButton(
                      text: 'Continue',
                      onPressed: _validateAndProceed,
                      size: size.width * widthFactor,
                    ),
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
