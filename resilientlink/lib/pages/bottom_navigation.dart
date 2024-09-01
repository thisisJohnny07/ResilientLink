import 'package:flutter/material.dart';
import 'package:resilientlink/pages/donations.dart';
import 'package:resilientlink/pages/home_page.dart';
import 'package:resilientlink/pages/messages.dart';
import 'package:resilientlink/pages/profile.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Donations(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToHome() {
    setState(() {
      _selectedIndex = 0; // Index for HomePage
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F8FF),
        title: GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 0; // Index for HomePage
            });
          },
          child: Image.asset(
            'images/logo.png',
            height: 40,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_support),
            color: const Color(0xFF015490),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Messages()));
            },
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF015490),
        onTap: _onItemTapped,
      ),
    );
  }
}
