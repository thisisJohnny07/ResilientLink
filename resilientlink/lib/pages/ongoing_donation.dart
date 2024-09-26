import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlink/Widget/progress.dart';
import 'package:resilientlink/outputs/items.dart';
import 'package:resilientlink/pages/bottom_navigation.dart';

class OngoingDonation extends StatefulWidget {
  const OngoingDonation({super.key});

  @override
  State<OngoingDonation> createState() => _OngoingDonationState();
}

class _OngoingDonationState extends State<OngoingDonation> {
  final CollectionReference aidDonation =
      FirebaseFirestore.instance.collection("aid_donation");

  Future<String> _fetchDonationDrive(String donationId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(donationId)
          .get();

      return doc.get('title') as String;
    } catch (e) {
      print(e);
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF015490),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Current Donation"),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: aidDonation.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data!;
            List<QueryDocumentSnapshot> documents = querySnapshot.docs;

            final user = FirebaseAuth.instance.currentUser;

            // Group donations by 'donationDriveId'
            Map<String, List<Map<String, dynamic>>> groupedDonations = {};

            for (var doc in documents) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['donorId'] == user?.uid) {
                final donationDriveId = data['donationDriveId'];
                if (groupedDonations.containsKey(donationDriveId)) {
                  groupedDonations[donationDriveId]!.add({
                    'documentId': doc.id,
                    ...data,
                  });
                } else {
                  groupedDonations[donationDriveId] = [
                    {'documentId': doc.id, ...data}
                  ];
                }
              }
            }

            if (groupedDonations.isEmpty) {
              return const Center(
                child: Text('No active Donation Drive posted'),
              );
            }
            return ListView.builder(
              itemCount: groupedDonations.length,
              itemBuilder: (context, index) {
                final donationDriveId = groupedDonations.keys.elementAt(index);
                final donations = groupedDonations[donationDriveId]!;

                // Use FutureBuilder to handle the asynchronous fetching of the title
                return FutureBuilder<String>(
                  future: _fetchDonationDrive(donationDriveId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display an alternative value while loading
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Loading donation title...',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Failed to load title',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      String donationTitle =
                          snapshot.data!; // Title has been fetched successfully

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the donation title
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF015490),
                                    Color(0xFF428CD4),
                                    Color(0xFF015490),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              padding: const EdgeInsets.all(10.0),
                              child: Flexible(
                                child: Text(
                                  donationTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        offset: Offset(1, 1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Display the list of donations under this donationDriveId
                            ...donations.map((donation) {
                              final documentId = donation['documentId'];
                              final Timestamp? timestamp =
                                  donation['createdAt'] as Timestamp?;
                              final DateTime? dateTime = timestamp?.toDate();
                              final String formattedDate = dateTime != null
                                  ? DateFormat('MMMM dd, yyyy – hh:mm a')
                                      .format(dateTime)
                                  : 'Unknown date';

                              return Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            donation['qrCode'] != null
                                                ? Image.network(
                                                    donation['qrCode'],
                                                    height: 50,
                                                  )
                                                : SizedBox(),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  formattedDate,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  documentId,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Column(
                                      children: [
                                        Progress(
                                          status: donation['status'],
                                        ),
                                        SizedBox(height: 20),
                                        Items(donationId: documentId),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF015490),
                                            foregroundColor: Colors.white,
                                            minimumSize:
                                                const Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            elevation: 2,
                                            shadowColor: Colors.black,
                                          ),
                                          onPressed: () {},
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.pin_drop),
                                              const Text("Navigate Drop Off"),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }

                    return const Text('No title available'); // Fallback case
                  },
                );
              },
            );
          }

          return const Center(
            child: Text('No Donation Drive posted'),
          );
        },
      ),
    );
  }
}
