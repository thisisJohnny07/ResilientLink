import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AidDonationConfirmation extends StatefulWidget {
  final List<Map<String, String>> items;
  final String donationDriveId;
  final String locationId;
  const AidDonationConfirmation(
      {super.key,
      required this.items,
      required this.donationDriveId,
      required this.locationId});

  @override
  State<AidDonationConfirmation> createState() =>
      _AidDonationConfirmationState();
}

class _AidDonationConfirmationState extends State<AidDonationConfirmation> {
  // To store the fetched donation data
  Map<String, dynamic>? location;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(widget.donationDriveId)
          .collection('location')
          .doc(widget.locationId)
          .get();

      if (doc.exists) {
        setState(() {
          location = doc.data() as Map<String, dynamic>? ?? {};
          isLoading = false;
        });
      } else {
        setState(() {
          location = {};
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        location = {};
        isLoading = false;
      });
    }
  }

  Future<void> submitDonation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      DocumentReference donationRef =
          await FirebaseFirestore.instance.collection('aid_donation').add({
        'donationDriveId': widget.donationDriveId,
        'donorId': user.uid,
        'locationId': widget.locationId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add item and quantity to the 'items' subcollection inside the donation document
      for (var item in widget.items) {
        if (item['item']!.isNotEmpty && item['quantity']!.isNotEmpty) {
          await donationRef.collection('items').add({
            'itemName': item['item'],
            'quantity': int.tryParse(item['quantity']!) ?? 0,
          });
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation submitted successfully!")),
      );

      // Pop to the previous screen or clear the form
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit donation: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF015490),
        foregroundColor: Colors.white,
        title: const Text("Confirm Donation"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Step 3:",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Review the items you're donating",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            const Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Color(0xFF015490),
                ),
                Text(
                  "Drop-off Point",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              location?['exactAdress'] ?? 'Loading location',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: Color(0xFF015490),
                ),
                Text(
                  "Goods List",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return Card(
                    color: const Color.fromARGB(255, 219, 235, 248),
                    child: ListTile(
                      title: Text(
                        "Item: ${item['item']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text("Quantity: ${item['quantity']}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: FloatingActionButton.extended(
          onPressed: () => submitDonation(context),
          backgroundColor: const Color(0xFF015490),
          label: const Text(
            "Confirm Donation",
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(
            Icons.check,
            color: Colors.white,
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
