import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlink/pages/donation_drive_details.dart';
import 'package:resilientlink/pages/donation_option.dart';
import 'package:share_plus/share_plus.dart';

class AllCurrentDonationDrive extends StatefulWidget {
  const AllCurrentDonationDrive({super.key});

  @override
  State<AllCurrentDonationDrive> createState() =>
      _AllCurrentDonationDriveState();
}

class _AllCurrentDonationDriveState extends State<AllCurrentDonationDrive> {
  @override
  Widget build(BuildContext context) {
    final CollectionReference donationDrive =
        FirebaseFirestore.instance.collection("donation_drive");

    Future<Map<String, dynamic>> _getDonationStatistics(
        String donationDriveId) async {
      final aidSnapshot = await FirebaseFirestore.instance
          .collection('aid_donation')
          .where('donationDriveId', isEqualTo: donationDriveId)
          .get();

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: donationDrive.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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

                  Map<String, Map<String, dynamic>> activeDrives = {
                    for (var doc in documents)
                      if ((doc.data() as Map<String, dynamic>)['isStart'] == 1)
                        doc.id: doc.data() as Map<String, dynamic>
                  };

                  int totalDonationDrive = activeDrives.length;

                  if (activeDrives.isEmpty) {
                    return const Center(
                      child: Text('No active Donation Drive posted'),
                    );
                  }

                  return Column(
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
                                  "Current Donation Initiatives",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                        children: activeDrives.entries.map((entry) {
                          final documentId = entry.key;
                          final donationDrive = entry.value;

                          final Timestamp? timestamp =
                              donationDrive['timestamp'] as Timestamp?;
                          final DateTime? dateTime = timestamp?.toDate();
                          final String formattedDate = dateTime != null
                              ? DateFormat('MMMM dd, yyyy – hh:mm a')
                                  .format(dateTime)
                              : 'Unknown date';

                          return FutureBuilder<Map<String, dynamic>>(
                            future: _getDonationStatistics(documentId),
                            builder: (context, snapshot) {
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
                                              donationDrive['title'] ??
                                                  'No Title',
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
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () async {
                                                final url =
                                                    "myapp://example.com";
                                                try {
                                                  await Share.share(url);
                                                } catch (e) {
                                                  print("Error sharing: $e");
                                                }
                                              },
                                              child: Icon(
                                                Icons.share,
                                                color: Colors.white,
                                              ),
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
                                                    "Packs Shared",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black45,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  donationDrive['isAid']
                                                      ? Text(
                                                          aidDonationCount
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        )
                                                      : Text('-'),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  const Text(
                                                    "Total Donations",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black45,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  donationDrive['isMonetary']
                                                      ? Text(
                                                          "₱${totalAmount.toStringAsFixed(2)}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        )
                                                      : Text('-'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor:
                                                        const Color(0xFF015490),
                                                    minimumSize: const Size(
                                                        double.infinity, 50),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    elevation: 2,
                                                    shadowColor: Colors.black,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DonationDriveDetails(
                                                                donationId:
                                                                    documentId),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text("Details"),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF015490),
                                                    foregroundColor:
                                                        Colors.white,
                                                    minimumSize: const Size(
                                                        double.infinity, 50),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DonationOption(
                                                          donationId:
                                                              documentId,
                                                          isAid: donationDrive[
                                                              'isAid'],
                                                          isMonetary:
                                                              donationDrive[
                                                                  'isMonetary'],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text("Donate"),
                                                ),
                                              ),
                                            ],
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
                      SizedBox(height: 10),
                      Text("Nothing Follows"),
                      SizedBox(height: 20)
                    ],
                  );
                }
                return const Center(
                  child: Text('No Donation Drive available.'),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
