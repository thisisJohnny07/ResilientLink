import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resilientlink/Widget/certificates.dart';
import 'package:resilientlink/Widget/list_menu.dart';
import 'package:resilientlink/pages/e_certificate.dart';
import 'package:resilientlink/pages/login.dart';
import 'package:resilientlink/pages/messages.dart';
import 'package:resilientlink/pages/ongoing_donation.dart';
import 'package:resilientlink/pages/ratings.dart';
import 'package:resilientlink/pages/to_rate.dart';
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
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const SizedBox(
                    height: 130,
                    width: 130,
                  ),
                ),
                Positioned(
                    top: 20,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.mail),
                      color: Colors.white,
                      onPressed: () async {
                        try {
                          // Fetch the admin data using a query (assuming there's only one admin)
                          var adminQuery = await FirebaseFirestore.instance
                              .collection('admin')
                              .where('isAdmin',
                                  isEqualTo:
                                      true) // Fetch the admin dynamically
                              .limit(
                                  1) // Limit to one admin, in case there are more
                              .get();

                          if (adminQuery.docs.isNotEmpty) {
                            var adminData = adminQuery.docs.first.data();

                            // Assuming adminData contains 'email' and 'uid' fields
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Messages(
                                  recieverEmail: adminData['email'],
                                  recieverID: adminData['uid'],
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                    )),
                Positioned(
                  bottom: -50,
                  left: (MediaQuery.of(context).size.width - 120) / 2,
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: .5,
                            blurRadius: 3,
                            offset: Offset(0, .2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          "${FirebaseAuth.instance.currentUser!.photoURL}",
                          fit: BoxFit.cover,
                        ),
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
                  const SizedBox(height: 10),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "My Donations",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ListMenu(
                    title: "Current Donation Drive",
                    icon: Icons.volunteer_activism,
                    onpress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OngoingDonation(
                            initialTabIndex: 0,
                          ),
                        ),
                      );
                    },
                  ),
                  ListMenu(
                    title: "To Rate",
                    icon: Icons.verified,
                    onpress: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ToRate()));
                    },
                  ),
                  ListMenu(
                    title: "Ratings and Reviews",
                    icon: Icons.star,
                    onpress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Ratings()),
                      );
                    },
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "E-Certificates",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ECertificate(),
                              ),
                            );
                          },
                          child: Text(
                            "See All",
                            style: TextStyle(
                              color: Color(0xFF015490),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Certificates(),
                  SizedBox(height: 10),
                  const Divider(),
                  ListMenu(
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
