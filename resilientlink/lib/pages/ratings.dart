import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Ratings extends StatelessWidget {
  const Ratings({super.key});

  Future<Map<String, dynamic>?> getDonationDriveDetails(
      String donationDriveId) async {
    final donationDriveDoc = await FirebaseFirestore.instance
        .collection('donation_drive')
        .doc(donationDriveId)
        .get();

    if (donationDriveDoc.exists) {
      return donationDriveDoc.data();
    }
    return null; // Return null if no data is found
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference ratingsCollection =
        FirebaseFirestore.instance.collection("ratings");

    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF015490),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Ratings"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ratingsCollection.snapshots(),
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
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

            // Filter and map the documents based on the current user's UID
            Set<Map<String, dynamic>> userRatings = documents
                .where((doc) =>
                    (doc.data() as Map<String, dynamic>)['donorId'] ==
                    FirebaseAuth.instance.currentUser?.uid)
                .map((doc) => {
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>,
                    })
                .toSet();

            // Check if no ratings available for the current user
            if (userRatings.isEmpty) {
              return const Center(
                child: Text('No ratings posted by you.'),
              );
            }

            // Convert the set to a list to display the ratings
            final List<Map<String, dynamic>> uniqueRatings =
                userRatings.toList();

            // Display the ratings list
            return ListView.builder(
              itemCount: uniqueRatings.length,
              itemBuilder: (context, index) {
                final rating = uniqueRatings[index];
                final String donationDriveId = rating['donationDriveId'];

                final Timestamp? timestamp = rating['timestamp'] as Timestamp?;
                final DateTime? dateTime = timestamp?.toDate();
                final String formattedDate = dateTime != null
                    ? DateFormat('MMMM dd, yyyy – hh:mm a').format(dateTime)
                    : 'Unknown date';

                return FutureBuilder<Map<String, dynamic>?>(
                  future: getDonationDriveDetails(donationDriveId),
                  builder: (context, donationDriveSnapshot) {
                    if (donationDriveSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    String? imageUrl =
                        donationDriveSnapshot.data?['image'] as String?;
                    String? title =
                        donationDriveSnapshot.data?['title'] as String?;

                    // Ensure that we retrieve and display the ratings field correctly
                    int ratingValue = rating['rating'] != null
                        ? rating['rating'].toInt() // Ensure it's an integer
                        : 0;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
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
                          // Display the image from the donation_drive collection with title overlay
                          if (imageUrl != null)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Text(
                                    title ?? 'No Title',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 0),
                                          blurRadius: 5,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Display star ratings based on the 'ratings' field
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < ratingValue
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.yellow[700],
                                        size: 20,
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox(
                              height: 200,
                              child: Center(
                                child: Text("No image available"),
                              ),
                            ),
                          const SizedBox(height: 10),

                          // Display Date
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: $formattedDate',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Display Feedback
                                Text(
                                  rating['feedback'] ?? 'No Feedback Provided',
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }

          return const Center(
            child: Text('No ratings available.'),
          );
        },
      ),
    );
  }
}
