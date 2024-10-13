import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resilientlink/Widget/list_menu.dart';
import 'package:resilientlink/pages/messages.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

class Hotlines extends StatefulWidget {
  const Hotlines({super.key});

  @override
  State<Hotlines> createState() => _HotlinesState();
}

class _HotlinesState extends State<Hotlines> {
  Map<String, dynamic>? hotline;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHotlines();
  }

  Future<void> _fetchHotlines() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('admin').limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;

        if (doc.exists) {
          setState(() {
            hotline = doc.data() as Map<String, dynamic>? ?? {};
            isLoading = false;
          });
        } else {
          setState(() {
            hotline = {};
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hotline = {};
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hotline = {};
        isLoading = false;
      });
    }
  }

  // Function to launch a URL
  Future<void> _launchURL(String url, bool website) async {
    if (website) {
      url = 'https://$url';
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

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
                // Gradient background with rounded bottom corners
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
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const SizedBox(
                    height: 300,
                  ),
                ),

                // AppBar inside the gradient container
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    title: const Text(
                      'Emergency Hotlines',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),

                // Centered User profile image and name
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.asset("images/pdrrmo.png")),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60.0,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF015490),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black,
                          ),
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
                          child: const Text("Chat Now"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        SizedBox(height: 10),
                        ListMenu(
                          title: "Email",
                          icon: Icons.mail,
                          onpress: () =>
                              _launchURL('mailto:${hotline?['email']}', false),
                          value: hotline?['email'],
                        ),
                        SizedBox(height: 5),
                        ListMenu(
                          title: "Smart hotline",
                          icon: Icons.sim_card,
                          onpress: () =>
                              _launchURL('tel:${hotline?['smart']}', false),
                          value: hotline?['smart'],
                        ),
                        SizedBox(height: 5),
                        ListMenu(
                          title: "Globe hotline",
                          icon: Icons.sim_card,
                          onpress: () =>
                              _launchURL('tel:${hotline?['globe']}', false),
                          value: hotline?['globe'],
                        ),
                        SizedBox(height: 5),
                        ListMenu(
                          title: "Telephone Number",
                          icon: Icons.call,
                          onpress: () =>
                              _launchURL('tel:${hotline?['phone']}', false),
                          value: hotline?['phone'],
                        ),
                        SizedBox(height: 5),
                        ListMenu(
                          title: "Facebook",
                          icon: Icons.facebook,
                          onpress: () =>
                              _launchURL(hotline?['facebookLink'], false),
                          value: hotline?['facebookName'],
                        ),
                        SizedBox(height: 5),
                        ListMenu(
                          title: "Website",
                          icon: Icons.language,
                          onpress: () => _launchURL(hotline?['website'], true),
                          value: hotline?['website'],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
