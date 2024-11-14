import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlink/pages/all_ended_donation_drive.dart';
import 'package:resilientlink/pages/completed_donation_drive_details.dart';

class EndedDonationDrive extends StatelessWidget {
  const EndedDonationDrive({super.key});

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

          // Filter only completed donation drives where isStart == 3
          List<Map<String, dynamic>> completedDrives = documents
              .where((drive) => drive['isStart'] == 3)
              .map((e) => {
                    'id': e.id,
                    ...e.data() as Map<String, dynamic>,
                  })
              .toList();

          int totalDonationDrive = completedDrives.length;

          if (completedDrives.isEmpty) {
            return const Center(
              child: Text('No Donation Drive Initiative Completed'),
            );
          }

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Completed Donation Initiatives",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 219, 235, 248),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.center,
                          width: 25,
                          height: 25,
                          child: Text(
                            totalDonationDrive.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllEndedDonationDrive()));
                      },
                      child: const Text(
                        "See all",
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF015490)),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: completedDrives.asMap().entries.map((entry) {
                    final index = entry.key;
                    final donationDrive = entry.value;

                    final Timestamp? timestamp =
                        donationDrive['timestamp'] as Timestamp?;
                    final DateTime? dateTime = timestamp?.toDate();
                    final String formattedDate = dateTime != null
                        ? DateFormat('MMMM dd, yyyy – hh:mm a').format(dateTime)
                        : 'Unknown date';

                    bool isLastItem = index == completedDrives.length - 1;

                    // Getting the donation statistics using the correct document ID
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getDonationStatistics(donationDrive['id']),
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
                          width: totalDonationDrive == 1 ? 300 : 260,
                          margin: EdgeInsets.only(
                            left: 16.0,
                            bottom: 30,
                            right: isLastItem ? 16.0 : 0,
                          ),
                          padding: const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
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
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              aidDonationCount.toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
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
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "₱${totalAmount.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
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
                                                donationId: donationDrive['id'],
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
              ),
            ],
          );
        }

        return const Center(
          child: Text("No data found."),
        );
      },
    );
  }
}
