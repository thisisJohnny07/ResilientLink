import 'package:flutter/material.dart';
import 'package:resilientlink/pages/donations.dart';
import 'package:resilientlink/pages/home_page.dart';
import 'package:resilientlink/pages/profile.dart';

class BottomNavigation extends StatefulWidget {
  final int initialIndex; // Add an initialIndex parameter

  const BottomNavigation(
      {super.key, this.initialIndex = 0}); // Default to 0 (Home)

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int _selectedIndex;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Donations(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        widget.initialIndex; // Set the selected index based on initialIndex
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
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
