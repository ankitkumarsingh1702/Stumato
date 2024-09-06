import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hushh_for_students_ios/auth/authviewmodel.dart';
import 'package:provider/provider.dart';

class SignOutScreen extends StatefulWidget {
  @override
  _SignOutScreenState createState() => _SignOutScreenState();
}

class _SignOutScreenState extends State<SignOutScreen> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User data
  String _firstName = '';
  String _lastName = '';
  String _emailAddress = '';
  String _phoneNumber = '';
  DateTime? _birthday;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data directly from Firestore
  Future<void> _fetchUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }

      final String userId = currentUser.uid;
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        if (!mounted) return; // Check if the widget is still mounted
        setState(() {
          _firstName = userDoc['firstName'] ?? '';
          _lastName = userDoc['lastName'] ?? '';
          _emailAddress = userDoc['emailAddress'] ?? '';
          _phoneNumber = userDoc['phoneNumber'] ?? '';
          _birthday = (userDoc['birthday'] as Timestamp?)?.toDate();
          _isLoading = false;
        });
      } else {
        print('User document not found in Firestore.');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<Authviewmodel>(context, listen: false);

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
                    'First Name: $_firstName',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Last Name: $_lastName',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Email: $_emailAddress',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Phone Number: $_phoneNumber',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Birthday: ${_birthday != null ? _birthday.toString() : 'Not set'}',
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
