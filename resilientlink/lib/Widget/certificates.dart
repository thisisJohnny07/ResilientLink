import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Certificates extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchCertificates() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('E-Certificates')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching E-Certificates: $e");
      return [];
    }
  }

  Future<String> _fetchDonationDriveTitle(String donationDriveId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(donationDriveId)
          .get();

      if (doc.exists) {
        return doc['title'] ?? 'Unknown Title';
      } else {
        return 'Unknown Title';
      }
    } catch (e) {
      print("Error fetching donation drive title: $e");
      return 'Unknown Title';
    }
  }

  void _launchPdf(String pdfUrl) async {
    if (await canLaunch(pdfUrl)) {
      await launch(pdfUrl);
    } else {
      throw 'Could not launch $pdfUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchCertificates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading certificates'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No E-Certificates found.'));
        }

        final certificates = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: certificates.map((certificate) {
              final pdfUrl = certificate['ECertificate'];
              final Timestamp? timestamp =
                  certificate['createdAt'] as Timestamp?;
              final DateTime? dateTime = timestamp?.toDate();
              final String formattedDate = dateTime != null
                  ? DateFormat('MMMM dd, yyyy – hh:mm a').format(dateTime)
                  : 'Unknown date';
              final String donationDriveId =
                  certificate['donationDriveId'] ?? 'Unknown Drive';

              return FutureBuilder<String>(
                future: _fetchDonationDriveTitle(donationDriveId),
                builder: (context, snapshot) {
                  final donationDriveTitle = snapshot.data ?? 'Loading...';

                  return GestureDetector(
                    onTap: () => _launchPdf(pdfUrl),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'images/certificate.png', // Ensure this asset exists
                            height: 40,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                donationDriveTitle,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("Date: $formattedDate"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
