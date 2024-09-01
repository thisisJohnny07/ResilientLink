import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  static var route;

  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
      ),
      body: const Center(
        child: Text("Home Page"),
      ),
    );
  }
}
