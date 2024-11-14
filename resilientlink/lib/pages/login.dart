import 'package:flutter/material.dart';
import 'package:resilientlink/pages/bottom_navigation.dart';
import 'package:resilientlink/services/google_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/login.jpg'), // Replace with your image path
                fit: BoxFit.cover, // Cover the entire scaffold
              ),
            ),
          ),
          // Foreground content
          Padding(
            padding: EdgeInsets.only(top: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: FloatingActionButton.extended(
          onPressed: () async {
            await FirebaseServices().signInWithGoogle();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigation(),
              ),
            );
          },
          backgroundColor: Color.fromARGB(120, 255, 255, 255),
          label: Row(
            mainAxisSize: MainAxisSize.min, // Make the Row as small as possible
            children: [
              Image.network(
                "https://cdn4.iconfinder.com/data/icons/logos-brands-7/512/google_logo-google_icongoogle-512.png",
                height: 35,
              ),
              SizedBox(width: 15),
              Text(
                "Continue with Google",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(2, .5),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
            ],
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
