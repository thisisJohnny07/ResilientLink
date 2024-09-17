import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlink/pages/donation_drive_details.dart';

class CurrentDonationDrive extends StatelessWidget {
  const CurrentDonationDrive({super.key});

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

          // Create a map of filtered documents with their IDs
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Current Donation Initiatives",
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
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // view all here
                      },
                      child: const Text(
                        "See all",
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF015490)),
                      ),
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: activeDrives.entries.map((entry) {
                    final documentId = entry.key;
                    final donationDrive = entry.value;

                    final Timestamp? timestamp =
                        donationDrive['timestamp'] as Timestamp?;
                    final DateTime? dateTime = timestamp?.toDate();
                    final String formattedDate = dateTime != null
                        ? DateFormat('MMMM dd, yyyy – hh:mm a').format(dateTime)
                        : 'Unknown date';

                    return Container(
                      width: totalDonationDrive == 1 ? 300 : 280,
                      margin: const EdgeInsets.only(left: 16.0, bottom: 30),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formattedDate),
                                const SizedBox(height: 10),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Packs Shared",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "100,00",
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Latest Donation",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "₱100,00",
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              const Color(0xFF015490),
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
                                                  DonationDriveDetails(
                                                      donationId: documentId),
                                            ),
                                          );
                                        },
                                        child: const Text("Details"),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
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
                                        ),
                                        onPressed: () {},
                                        child: const Text("Donate"),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          );
        }
        return const Center(
          child: Text('No Donation Drive posted'),
        );
      },
    );
  }
}