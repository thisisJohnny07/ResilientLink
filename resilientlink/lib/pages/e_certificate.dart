import 'package:flutter/material.dart';

class ECertificate extends StatelessWidget {
  const ECertificate({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Two Tab Navigation'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Tab 1"),
              Tab(text: "Tab 2"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Tab1Content(),
            Tab2Content(),
          ],
        ),
      ),
    );
  }
}

class Tab1Content extends StatelessWidget {
  const Tab1Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Content of Tab 1',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class Tab2Content extends StatelessWidget {
  const Tab2Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Content of Tab 2',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
