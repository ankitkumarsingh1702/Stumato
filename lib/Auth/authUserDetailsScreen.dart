import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../HomeScreens/home.dart';


class AuthUserDetailsScreen extends StatefulWidget {
  final User? user;

  const AuthUserDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AuthUserDetailsScreen> createState() => _AuthUserDetailsScreenState();
}

class _AuthUserDetailsScreenState extends State<AuthUserDetailsScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  DateTime? _selectedBirthday;
  String? _errorText;

  bool _isSaving = false;

  // Function to save user details to Firestore
  Future<void> _saveUserDetails() async {
    setState(() {
      _isSaving = true;
    });

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final email = widget.user?.email ?? '';
    final uid = widget.user?.uid ?? '';
    final profilePicUrl = widget.user?.photoURL ?? '';

    // Basic validation
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phoneNumber.isEmpty ||
        _selectedBirthday == null) {
      setState(() {
        _errorText = 'All fields are required.';
        _isSaving = false;
      });
      return;
    }

    try {
      // Create a reference to the Firestore collection
      CollectionReference users =
      FirebaseFirestore.instance.collection('user_stumato');

      // Create a document with UID as the document ID
      await users.doc(uid).set({
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'email': email,
        'birthday': _selectedBirthday?.toIso8601String(),
        'profile_pic_url': profilePicUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Navigate to the main application screen or dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthUserDetailsSuccessScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _errorText = 'Failed to save details. Please try again.';
      });
      print('Error saving user details: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Function to handle date selection
  void _onDateSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _selectedBirthday = args.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double widthFactor = 0.85;

    return Scaffold(
      // Custom AppBar with gradient from Figma design
      appBar: AppBar(
        title: Text(
          'Your Details',
          style: GoogleFonts.figtree(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(18, 24, 60, 1.0), // Start color
                Color.fromRGBO(42, 57, 122, 1.0), // End color

              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/app_bg.jpeg', // Background image
              fit: BoxFit.cover, // Ensures the image covers the entire background
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: size.height * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const GradientProgressBar(
                  //   progress: 0.2, // Update progress as per the step
                  // ),
                  const SizedBox(height: 24),
                  Text(
                    'Complete Your Profile',
                    style: GoogleFonts.figtree(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffe9ebee),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // First Name
                  SizedBox(
                    width: size.width * widthFactor,
                    child: CustomTextBox(
                      controller: _firstNameController,
                      hintText: 'First Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Last Name
                  SizedBox(
                    width: size.width * widthFactor,
                    child: CustomTextBox(
                      controller: _lastNameController,
                      hintText: 'Last Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Phone Number
                  SizedBox(
                    width: size.width * widthFactor,
                    child: CustomTextBox(
                      controller: _phoneNumberController,
                      hintText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Birthday Picker
                  Text(
                    'Select Your Birthday',
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SfDateRangePicker(
                    onSelectionChanged: _onDateSelectionChanged,
                    selectionMode: DateRangePickerSelectionMode.single,
                    initialSelectedDate: _selectedBirthday,
                    initialDisplayDate: DateTime(2000),
                    maxDate: DateTime.now(),
                    monthViewSettings: const DateRangePickerMonthViewSettings(
                      firstDayOfWeek: 1, // Monday
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorText != null)
                    Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: size.width * widthFactor,
                    child: _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _saveUserDetails,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent, // No shadow
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
                          borderRadius:
                          BorderRadius.all(Radius.circular(22.0)),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(
                            maxWidth: 342.0,
                            minHeight: 44.0,
                          ),
                          child: Text(
                            'Save Details',
                            style: GoogleFonts.figtree(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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

// Success Screen after saving details
class AuthUserDetailsSuccessScreen extends StatelessWidget {
  const AuthUserDetailsSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/app_bg.jpeg', // Background image
              fit: BoxFit.cover, // Ensures the image covers the entire background
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.greenAccent,
                      size: 100,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Profile Updated Successfully!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.figtree(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the main application screen or dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainAppScreen(), // Reference the new MainAppScreen from home.dart
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                        backgroundColor: const Color(0xFFA342FF),
                        shadowColor: Colors.transparent, // Remove shadow
                      ),
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Custom TextBox Widget
class CustomTextBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  const CustomTextBox({
    Key? key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      style: GoogleFonts.figtree(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.figtree(
          color: Colors.white54,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
    );
  }
}

// Custom Gradient Progress Bar (Updated Progress)
class GradientProgressBar extends StatelessWidget {
  final double progress;

  const GradientProgressBar({Key? key, required this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress,
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE54D60)),
      backgroundColor: const Color(0xFFA342FF),
      minHeight: 8,
    );
  }
}
