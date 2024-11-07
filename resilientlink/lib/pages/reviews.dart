import 'package:flutter/material.dart';
import 'package:resilientlink/pages/bottom_navigation.dart';
import 'package:resilientlink/pages/ratings.dart';
import 'package:resilientlink/pages/to_rate.dart';

class Reviews extends StatelessWidget {
  final int initialTabIndex;

  const Reviews({super.key, required this.initialTabIndex});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex, // Use the passed index
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF015490),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(" Ratings and Reviews"),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomNavigation(initialIndex: 2),
                ),
              );
            },
          ),
        ),
        body: Column(
          children: [
            // TabBar without placing it inside the AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              color: const Color(0xFFf1f4f4),
              child: const TabBar(
                labelColor: Colors.black,
                indicatorColor: Color(0xFF015490),
                tabs: [
                  Tab(text: "Ratings"),
                  Tab(text: "To Rate"),
                ],
              ),
            ),
            // TabBarView that switches between the two tab contents
            Expanded(
              child: const TabBarView(
                children: [
                  Ratings(),
                  ToRate(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
