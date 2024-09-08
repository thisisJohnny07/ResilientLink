import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resilientlink/pages/login.dart';
import 'package:resilientlink/services/google_auth.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF015490),
                        Color(0xFF428CD4),
                        Color(0xFF015490),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(25, 20),
                      bottomRight: Radius.elliptical(25, 20),
                    ),
                  ),
                  child: const SizedBox(
                    height: 130,
                    width: 130,
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: (MediaQuery.of(context).size.width - 120) / 2,
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        "${FirebaseAuth.instance.currentUser!.photoURL}",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 50.0, horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "${FirebaseAuth.instance.currentUser!.displayName}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${FirebaseAuth.instance.currentUser!.email}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF015490),
                      ),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  ProfileMenu(
                    title: "Personal Information",
                    icon: Icons.person,
                    onpress: () {},
                  ),
                  ProfileMenu(
                    title: "E-Certificates",
                    icon: Icons.verified,
                    onpress: () {},
                  ),
                  ProfileMenu(
                    title: "Reviews",
                    icon: Icons.star,
                    onpress: () {},
                  ),
                  ProfileMenu(
                    title: "Logout",
                    icon: Icons.logout,
                    onpress: () {},
                  ),
                  const Divider(),
                  ProfileMenu(
                    title: "Logout",
                    icon: Icons.logout,
                    onpress: () async {
                      await FirebaseServices().googleSignOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    textColor: Colors.red,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu(
      {super.key,
      required this.title,
      required this.icon,
      required this.onpress,
      this.textColor});

  final String title;
  final IconData icon;
  final VoidCallback onpress;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onpress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: const Color(0xFF015490).withOpacity(0.1)),
        child: Icon(
          icon,
          color: const Color(0xFF015490),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16).apply(color: textColor),
      ),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey.withOpacity(0.1)),
        child: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 18,
        ),
      ),
    );
  }
}
