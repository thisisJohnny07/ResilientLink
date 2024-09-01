import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Donations extends StatelessWidget {
  const Donations({super.key});

  static const route = '/notification-screen';

  @override
  Widget build(BuildContext context) {
    final message =
        ModalRoute.of(context)!.settings.arguments as RemoteMessage?;

    if (message == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Push Notification'),
        ),
        body: const Center(
          child: Text('No message data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${message.notification?.title}'),
            Text('${message.notification?.body}'),
            Text("${message.data}"),
          ],
        ),
      ),
    );
  }
}
