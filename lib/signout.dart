import 'package:flutter/material.dart';
import 'package:hushh_for_students_ios/auth/authviewmodel.dart';
import 'package:provider/provider.dart';

class SignOutScreen extends StatefulWidget {
  @override
  _SignOutScreenState createState() => _SignOutScreenState();
}

class _SignOutScreenState extends State<SignOutScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch user data when the widget is initialized
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authViewModel = Provider.of<Authviewmodel>(context, listen: false);

    try {
      await authViewModel
          .fetchUserDataFromFirestore(); // Fetch user data from ViewModel
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<Authviewmodel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Out'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'First Name: ${authViewModel.firstName}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Last Name: ${authViewModel.lastName}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Email: ${authViewModel.emailAddress}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Phone Number: ${authViewModel.phoneNumber}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Birthday: ${authViewModel.birthday != null ? authViewModel.birthday.toString() : 'Not set'}',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Sign out from Firebase and Google
                      await authViewModel.signOut();

                      // Navigate to the login screen
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
      ),
    );
  }
}
