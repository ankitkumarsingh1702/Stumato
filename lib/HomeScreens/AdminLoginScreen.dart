import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AdminDashboard.dart';


class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Removed hardcoded credentials
  String? adminEmail;
  String? adminPassword;

  final _formKey = GlobalKey<FormState>();
  bool _isLoggingIn = false;
  bool _isLoadingCredentials = true;

  @override
  void initState() {
    super.initState();
    _listenToAdminCredentials();
  }

  void _listenToAdminCredentials() {
    FirebaseFirestore.instance
        .collection('user_admin')
        .doc('admincred')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          adminEmail = snapshot.get('adminEmail') as String?;
          adminPassword = snapshot.get('adminPassword') as String?;
          _isLoadingCredentials = false;
        });
      } else {
        setState(() {
          adminEmail = null;
          adminPassword = null;
          _isLoadingCredentials = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin credentials not found in Firestore.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }, onError: (error) {
      setState(() {
        _isLoadingCredentials = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching admin credentials: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  void _attemptAdminLogin() {
    if (_formKey.currentState!.validate()) {
      if (adminEmail == null || adminPassword == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin credentials are not available.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        _isLoggingIn = true;
      });

      // Simulate a delay for authentication
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoggingIn = false;
        });

        if (_emailController.text.trim() == adminEmail &&
            _passwordController.text.trim() == adminPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Successful'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Navigate to Admin Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid credentials'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Widget for input fields similar to MyProfileScreen
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Slightly off-white
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.figtree(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold, // Bold label
          ),
          border: InputBorder.none,
          prefixIcon: label == 'Email'
              ? const Icon(Icons.email, color: Colors.grey)
              : const Icon(Icons.lock, color: Colors.grey),
        ),
        style: GoogleFonts.figtree(
          fontSize: 16,
          fontWeight: FontWeight.normal, // Normal text
          color: Colors.black,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your ${label.toLowerCase()}';
          }
          if (label == 'Email') {
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
              return 'Please enter a valid email';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match the profile screen's background
      appBar: AppBar(
        title: Text(
          'Admin Login',
          style: GoogleFonts.figtree(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEE764D), // Match profile screen's AppBar color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoadingCredentials
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Welcome Back, Admin!',
                        style: GoogleFonts.figtree(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please login to continue',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Email Field
                      _buildInputField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      _buildInputField(
                        label: 'Password',
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),
                      // Login Button
                      _isLoggingIn
                          ? const CircularProgressIndicator()
                          : SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _attemptAdminLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFFEE764D), // Match AppBar color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.figtree(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
