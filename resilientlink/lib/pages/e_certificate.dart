import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ECertificate extends StatefulWidget {
  @override
  State<ECertificate> createState() => _ECertificateState();
}

class _ECertificateState extends State<ECertificate> {
  List<Map<String, dynamic>> eCertificates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchECertificates();
  }

  Future<void> _fetchECertificates() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch all documents where userId matches the current user's uid
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('E-Certificates')
          .where('userId', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          eCertificates = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          eCertificates = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching E-Certificates: $e");
      setState(() {
        eCertificates = [];
        isLoading = false;
      });
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF015490),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("E-Certificates"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : eCertificates.isNotEmpty
              ? ListView.builder(
                  itemCount: eCertificates.length,
                  itemBuilder: (context, index) {
                    final certificate = eCertificates[index];
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
                        final donationDriveTitle =
                            snapshot.data ?? 'Loading...';

                        return GestureDetector(
                          onTap: () => _launchPdf(pdfUrl),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                  },
                )
              : Center(child: Text('No E-Certificates found.')),
    );
  }
}
