import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hushh_for_students_ios/MainAct/webact.dart';
import 'package:hushh_for_students_ios/auth/authviewmodel.dart';
import 'package:hushh_for_students_ios/components/customButton.dart';
import 'package:hushh_for_students_ios/home.dart';
import 'package:hushh_for_students_ios/onboarding/components/customProgressIndicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BirthDateScreen extends StatefulWidget {
  const BirthDateScreen({super.key});

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  final TextEditingController _dateController = TextEditingController();
  String? _errorText;
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default to year 2000
      firstDate: DateTime(1900), // Set the earliest date available
      lastDate: DateTime.now(), // Current date is the maximum selectable
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            DateFormat('dd/MM/yyyy').format(picked); // Format and display date
      });
    }
  }

  void _validateAndProceed() {
    final birthdate = _dateController.text;

    if (birthdate.isEmpty) {
      setState(() {
        _errorText = 'Date of birth cannot be empty';
      });
    } else {
      try {
        final DateTime parsedDate =
            DateFormat('dd/MM/yyyy').parseStrict(birthdate);
        if (parsedDate.isAfter(DateTime.now())) {
          setState(() {
            _errorText = 'Enter a valid date of birth';
          });
        } else {
          final viewModel = Provider.of<Authviewmodel>(context, listen: false);
          viewModel.updateBirthday(parsedDate); // Update ViewModel
          viewModel.updateUserInFirestore();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MainScreen(), // Replace with your next screen
            ),
          );
          setState(() {
            _errorText = null;
          });
        }
      } catch (e) {
        setState(() {
          _errorText = 'Enter a valid date of birth';
        });
      }
    }
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
                image: AssetImage(
                    'lib/assets/app_bg.jpeg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  const GradientProgressBar(
                    progress:
                        0.4, // Set the current step for the birthdate screen
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Text(
                    'My Date of Birth is',
                    style: GoogleFonts.figtree(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffe9ebee),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Responsive TextField for date input
                  SizedBox(
                    width: size.width * widthFactor,
                    child: GestureDetector(
                      onTap: () => _selectDate(context), // Open date picker
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter your date of birth',
                            errorText: _errorText,
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Responsive Button
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
