import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlink/Widget/progress.dart';
import 'package:resilientlink/Widget/qr_dialog_box.dart';
import 'package:resilientlink/outputs/items.dart';
import 'package:resilientlink/pages/navigate.dart';

class OngoingAidDonation extends StatefulWidget {
  const OngoingAidDonation({super.key});

  @override
  State<OngoingAidDonation> createState() => _OngoingDonationState();
}

class _OngoingDonationState extends State<OngoingAidDonation>
    with AutomaticKeepAliveClientMixin<OngoingAidDonation> {
  @override
  bool get wantKeepAlive => true;
  final CollectionReference aidDonation =
      FirebaseFirestore.instance.collection("aid_donation");

  Future<String> _fetchDonationDrive(String donationId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(donationId)
          .get();

      // Check if 'isStart' is 1 before returning the title
      if (doc.exists && doc.get('isStart') == 1) {
        return doc.get('title') as String;
      }
      return ''; // Return an empty string if 'isStart' is not 1
    } catch (e) {
      print(e);
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      body: StreamBuilder<QuerySnapshot>(
        stream: aidDonation.where('status', isNotEqualTo: 2).snapshots(),
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
                child: Text('No active Donation'),
              );
            }

            List<Widget> donationWidgets = [];

            return FutureBuilder<List<String>>(
              future: Future.wait(
                  groupedDonations.keys.map((donationDriveId) async {
                String title = await _fetchDonationDrive(donationDriveId);
                return title.isNotEmpty ? title : '';
              })),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                List<String> titles =
                    snapshot.data!.where((title) => title.isNotEmpty).toList();

                if (titles.isEmpty) {
                  return const Center(
                    child: Text('No active Donation'),
                  );
                }

                for (int i = 0; i < titles.length; i++) {
                  String title = titles[i];
                  final donationDriveId = groupedDonations.keys.elementAt(i);
                  final donations = groupedDonations[donationDriveId]!;

                  if (title.isNotEmpty) {
                    donationWidgets.add(
                      Container(
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
                                borderRadius: const BorderRadius.only(
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
                              child: Text(
                                title,
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
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            if (donation['qrCode'] != null)
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        QrDialogBox(
                                                      image: donation['qrCode'],
                                                    ),
                                                  );
                                                },
                                                child: Image.network(
                                                  donation['qrCode'],
                                                  height: 50,
                                                ),
                                              ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  formattedDate,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  "# $documentId",
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
                                        const SizedBox(height: 20),
                                        Items(donationId: documentId),
                                        const SizedBox(height: 20),
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
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Navigate(
                                                  locationId:
                                                      donation['locationId'],
                                                  donationDriveId: donation[
                                                      'donationDriveId'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.pin_drop),
                                              Text("Navigate Drop Off"),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }
                }

                return ListView(
                  children: donationWidgets,
                );
              },
            );
          }

          return const Center(
            child: Text('No active Donation'),
          );
        },
      ),
    );
  }
}
