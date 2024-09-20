import 'package:flutter/material.dart';
import 'package:hushh_for_students_ios/auth/authviewmodel.dart';
import 'package:hushh_for_students_ios/onboarding/onBoardingScreen.dart';
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
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authViewModel = Provider.of<Authviewmodel>(context, listen: false);

    try {
      await authViewModel.fetchUserDataFromFirestore();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/app_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: ClipPath(
                clipper: CurvedBackgroundClipper(),
                child: Container(
                  height: screenHeight * 0.68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0A0C18), Color(0xFF320A3B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Column(
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/Frame.png',
                                  width: screenWidth * 0.5,
                                  height: screenWidth * 0.5,
                                  fit: BoxFit.cover,
                                ),
                                CircleAvatar(
                                  radius: screenWidth * 0.18,
                                  backgroundImage:
                                      NetworkImage(authViewModel.profilePicUrl),
                                ),
                                Positioned(
                                  bottom: -1,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01,
                                        horizontal: screenWidth * 0.05),
                                    width: screenWidth * 0.35,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFE54D60),
                                          Color(0xFFA342FF),
                                        ],
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Color.fromRGBO(33, 37, 41, 0.3),
                                          blurRadius: 3,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Profile',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              authViewModel.firstName,
                              style: TextStyle(
                                fontSize: screenWidth * 0.07,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Spacer(), // Spacer to push the button to the bottom
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenHeight * 0.02),
                                child: Column(
                                  children: [
                                    const Text(
                                      'hushh Platinum™',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    const Text(
                                      'Level up every action you take on hushh',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(height: screenHeight * 0.05),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await authViewModel.signOut();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OnboardingScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.1,
                                            vertical: screenHeight * 0.02),
                                      ),
                                      child: Text(
                                        'Sign out',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CurvedBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 100);

    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 100);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
