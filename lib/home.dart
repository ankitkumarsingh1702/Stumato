import 'package:flutter/material.dart';
import 'package:hushh_for_students_ios/MainAct/webact.dart';
import 'package:hushh_for_students_ios/discoverScreen.dart';
import 'package:hushh_for_students_ios/signout.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens = [
      const WebAct(),
      Discoverscreen(),
      SignOutScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            _buildBottomNavigationBarItem(0, 'home_nav.png'),
            _buildBottomNavigationBarItem(1, 'explore_nav.png'),
            _buildBottomNavigationBarItem(2, 'profile_nav.png'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xff111418),
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      int index, String iconPath) {
    return BottomNavigationBarItem(
      icon: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Image.asset(
          'lib/assets/$iconPath',
          width: 56,
          height: 56,
          color: _selectedIndex == index ? Colors.purple : Colors.grey,
        ),
      ),
      label: '',
    );
  }
}
