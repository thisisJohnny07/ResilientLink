import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlink/pages/completed_donation_drive_details.dart';

class AllEndedDonationDrive extends StatefulWidget {
  const AllEndedDonationDrive({super.key});

  @override
  State<AllEndedDonationDrive> createState() => _AllEndedDonationDriveState();
}

class _AllEndedDonationDriveState extends State<AllEndedDonationDrive> {
  Future<Map<String, dynamic>> _getDonationStatistics(
      String donationDriveId) async {
    final aidSnapshot = await FirebaseFirestore.instance
        .collection('aid_donation')
        .where('donationDriveId', isEqualTo: donationDriveId)
        .where('status', whereIn: [1, 2]).get();

    final moneySnapshot = await FirebaseFirestore.instance
        .collection('money_donation')
        .where('donationDriveId', isEqualTo: donationDriveId)
        .get();

    int aidDonationCount = aidSnapshot.docs.length;

    double totalAmount = 0.0;
    for (var doc in moneySnapshot.docs) {
      totalAmount += (doc.data()['amount'] as num).toDouble();
    }

    return {
      'aidDonationCount': aidDonationCount,
      'totalAmount': totalAmount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference donationDrive =
        FirebaseFirestore.instance.collection("donation_drive");

    return StreamBuilder<QuerySnapshot>(
      stream: donationDrive.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          QuerySnapshot querySnapshot = snapshot.data!;
          List<QueryDocumentSnapshot> documents = querySnapshot.docs;

          // Filter only completed donation drives where isStart == 3, and include the document ID
          List<Map<String, dynamic>> completedDrives = documents
              .where((doc) => doc['isStart'] == 3)
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  })
              .toList();

          int totalDonationDrive = completedDrives.length;

          if (completedDrives.isEmpty) {
            return const Center(
                child: Text('No Donation Drive Initiative Completed'));
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 50, left: 20, right: 20, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Completed Donation Initiatives",
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 15),
                            Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 219, 235, 248),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              width: 30,
                              height: 30,
                              child: Text(
                                totalDonationDrive.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: completedDrives.map((donationDrive) {
                      final Timestamp? timestamp =
                          donationDrive['timestamp'] as Timestamp?;
                      final DateTime? dateTime = timestamp?.toDate();
                      final String formattedDate = dateTime != null
                          ? DateFormat('MMMM dd, yyyy – hh:mm a')
                              .format(dateTime)
                          : 'Unknown date';

                      // Getting the donation statistics using the document ID
                      return FutureBuilder<Map<String, dynamic>>(
                        future: _getDonationStatistics(
                            donationDrive['id'] as String),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          int aidDonationCount =
                              snapshot.data?['aidDonationCount'] ?? 0;
                          double totalAmount =
                              snapshot.data?['totalAmount'] ?? 0.0;

                          return Container(
                            margin: const EdgeInsets.only(
                                top: 20, bottom: 10, left: 20, right: 20),
                            padding: const EdgeInsets.only(bottom: 30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        height: 200,
                                        width: double.infinity,
                                        child: Image.network(
                                          donationDrive['image'] as String,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        right: 8,
                                        child: Text(
                                          donationDrive['title'] ?? 'No Title',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                offset: Offset(1, 1),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Icon(
                                          Icons.share,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(formattedDate),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Packs Collected",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black45),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                aidDonationCount.toString(),
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                "Money Collected",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black45),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                "₱${totalAmount.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Center(
                                        child: ElevatedButton(
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
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CompletedDonationDriveDetails(
                                                  donationId:
                                                      donationDrive['id'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text("Details"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Text("Nothing Follows"),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('No Donation Drive posted'));
      },
    );
  }
}
