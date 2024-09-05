import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hushh_for_students_ios/auth/authBirthDayScreen.dart';

class Authviewmodel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isLoading = false;
  String? _userId;

  // User data
  String _firstName = '';
  String _lastName = '';
  String _emailAddress = '';
  String _phoneNumber = '';
  DateTime? _birthday;

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get emailAddress => _emailAddress;
  String get phoneNumber => _phoneNumber;
  DateTime? get birthday => _birthday;
  String? get userId => _userId;

  // Check if user is already authenticated
  Future<void> checkAuthentication(BuildContext context) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      await fetchUserDataFromFirestore();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _userId = user.uid;
        _emailAddress = user.email ?? '';
        _phoneNumber = user.phoneNumber ?? '';
        await _createUserInFirestore(); // Create or update user in Firestore
        isLoading = false;
        notifyListeners();

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const BirthDateScreen()));
      }
    } catch (e) {
      print("Error in Google Sign-In: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user data from Firestore
  Future<void> fetchUserDataFromFirestore() async {
    if (_userId == null) return;

    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_userId).get();

      if (userDoc.exists) {
        _firstName = userDoc['firstName'] ?? '';
        _lastName = userDoc['lastName'] ?? '';
        _emailAddress = userDoc['emailAddress'] ?? '';
        _phoneNumber = userDoc['phoneNumber'] ?? '';
        _birthday = (userDoc['birthday'] as Timestamp?)?.toDate();
        notifyListeners();
      } else {
        print('No user document found in Firestore.');
      }
    } catch (e) {
      print('Error fetching user data from Firestore: $e');
    }
  }

  // Create or update user in Firestore
  Future<void> _createUserInFirestore() async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).set({
        'firstName': _firstName.isNotEmpty ? _firstName : null,
        'lastName': _lastName.isNotEmpty ? _lastName : null,
        'emailAddress': _emailAddress.isNotEmpty ? _emailAddress : null,
        'phoneNumber': _phoneNumber.isNotEmpty ? _phoneNumber : null,
        'birthday': _birthday != null ? _birthday : null,
      }, SetOptions(merge: true)); // Merges with existing data if any

      notifyListeners();
    } catch (e) {
      print('Error creating/updating user in Firestore: $e');
    }
  }

  // Update Firestore with user data
  Future<void> updateUserInFirestore() async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'firstName': _firstName,
        'lastName': _lastName,
        'emailAddress': _emailAddress,
        'phoneNumber': _phoneNumber,
        'birthday': _birthday,
      });
      notifyListeners();
    } catch (e) {
      print('Error updating user in Firestore: $e');
    }
  }

  // Update methods for individual fields
  void updateFirstName(String firstName) {
    _firstName = firstName;
    updateUserInFirestore();
  }

  void updateLastName(String lastName) {
    _lastName = lastName;
    updateUserInFirestore();
  }

  void updateEmailAddress(String emailAddress) {
    _emailAddress = emailAddress;
    updateUserInFirestore();
  }

  void updatePhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    updateUserInFirestore();
  }

  void updateBirthday(DateTime birthday) {
    _birthday = birthday;
    updateUserInFirestore();
  }
}
