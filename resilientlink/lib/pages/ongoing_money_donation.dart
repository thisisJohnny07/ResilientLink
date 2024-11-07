import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OngoingMoneyDonation extends StatefulWidget {
  const OngoingMoneyDonation({super.key});

  @override
  State<OngoingMoneyDonation> createState() => _OngoingDonationState();
}

class _OngoingDonationState extends State<OngoingMoneyDonation>
    with AutomaticKeepAliveClientMixin<OngoingMoneyDonation> {
  @override
  bool get wantKeepAlive => true;
  final CollectionReference moneyDonation =
      FirebaseFirestore.instance.collection("money_donation");

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
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            moneyDonation.where('isDelivered', isEqualTo: false).snapshots(),
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
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.network(
                                            donation['modeOfPayment'] == 'gcash'
                                                ? "https://seeklogo.com/images/G/gcash-logo-E93133FDA5-seeklogo.com.png"
                                                : donation['modeOfPayment'] ==
                                                        'paymaya'
                                                    ? "https://cdn.manilastandard.net/wp-content/uploads/2022/05/maya.jpg"
                                                    : donation['modeOfPayment'] ==
                                                            'card'
                                                        ? "https://thumbs.dreamstime.com/b/kiev-ukraine-september-visa-mastercard-logos-printed-white-paper-visa-mastercard-american-multinational-102631953.jpg"
                                                        : "https://your-credit-card-logo-url.com",
                                            height: 50,
                                            width: 55,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
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
                                              "ref# ${donation['referenceNumber']}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              'Amount: \u20B1 ${donation['amount']}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
