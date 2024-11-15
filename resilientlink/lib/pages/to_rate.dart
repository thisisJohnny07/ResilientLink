import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resilientlink/Widget/mov_dialog_box.dart';
import 'package:resilientlink/Widget/rate_donation_drive.dart';

class ToRate extends StatefulWidget {
  const ToRate({super.key});

  @override
  State<ToRate> createState() => _ToRateState();
}

class _ToRateState extends State<ToRate> {
  bool isLoading = false;
  Set<String> uniqueDonationId = {}; // To store donation drive IDs
  Map<String, DocumentSnapshot> donationDriveDocs =
      {}; // To store full donation drive documents

  @override
  void initState() {
    super.initState();
    _fetchDonation();
  }

  Future<void> _fetchDonation() async {
    setState(() {
      isLoading = true;
    });

    try {
      final donorId = FirebaseAuth.instance.currentUser?.uid;

      // Fetch aid donations
      QuerySnapshot aidDonationSnapshot = await FirebaseFirestore.instance
          .collection('aid_donation')
          .where('donorId', isEqualTo: donorId)
          .where('status', isEqualTo: 2)
          .where('isRated', isEqualTo: false)
          .get();

      // Fetch money donations
      QuerySnapshot moneyDonationSnapshot = await FirebaseFirestore.instance
          .collection('money_donation')
          .where('donorId', isEqualTo: donorId)
          .where('isDelivered', isEqualTo: true)
          .where('isRated', isEqualTo: false)
          .get();

      // Collect unique donationDriveId from both collections
      for (var donationDoc in aidDonationSnapshot.docs) {
        String donationDriveId = donationDoc['donationDriveId'];
        uniqueDonationId.add(donationDriveId);
      }

      for (var donationDoc in moneyDonationSnapshot.docs) {
        String donationDriveId = donationDoc['donationDriveId'];
        uniqueDonationId.add(donationDriveId);
      }

      // Fetch full document snapshots from donation_drive collection
      for (String donationDriveId in uniqueDonationId) {
        DocumentSnapshot donationDriveSnapshot = await FirebaseFirestore
            .instance
            .collection('donation_drive')
            .doc(donationDriveId)
            .get();

        if (donationDriveSnapshot.exists) {
          setState(() {
            donationDriveDocs[donationDriveId] = donationDriveSnapshot;
          });
        }
      }
    } catch (e) {
      print('Error fetching donation data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
        title: const Text("To Rate"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : donationDriveDocs.isEmpty
              ? const Center(
                  child: Text("No donation drives available for feedback"))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Help Us Grow",
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          Text(
                            "Provide feedback and ratings to claim your e-certificate and help us enhance our service!",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      itemCount: donationDriveDocs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        String donationDriveId =
                            donationDriveDocs.keys.elementAt(index);
                        DocumentSnapshot donationDriveDoc =
                            donationDriveDocs[donationDriveId]!;

                        return Container(
                          margin: EdgeInsets.only(
                            right: 16,
                            left: 16,
                            bottom: 16,
                          ),
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
                                      height: 100,
                                      width: double.infinity,
                                      child: Image.network(
                                        donationDriveDoc['image'] as String,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Text(
                                        donationDriveDoc['title'] ?? 'No Title',
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
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        minimumSize: const Size(150, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        elevation: 2,
                                        shadowColor: Colors.black,
                                      ),
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return MovDialogBox(
                                                donationDriveId:
                                                    donationDriveId);
                                          },
                                        );
                                        setState(() {});
                                      },
                                      child: const Text("mov"),
                                    ),
                                    const SizedBox(
                                        width: 10), // Space between the buttons
                                    // Second Button: "rate"
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF015490),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(150,
                                            50), // Same fixed width as the first button
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        elevation: 2,
                                        shadowColor: Colors.black,
                                      ),
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return RateDonationDrive(
                                                donationDriveId:
                                                    donationDriveId);
                                          },
                                        );
                                        setState(() {});
                                      },
                                      child: const Text("rate"),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}
