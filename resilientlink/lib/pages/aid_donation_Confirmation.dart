import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resilientlink/pages/generate_qr.dart';

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
  bool _isLoading = false;
  late String newDonationId;

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
          _isLoading = false;
        });
      } else {
        setState(() {
          location = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        location = {};
        _isLoading = false;
      });
    }
  }

  Future<void> submitDonation(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
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
        'status': 0,
        'isRated': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      newDonationId = donationRef.id;

      // Add item and quantity to the 'items' subcollection inside the donation document
      for (var item in widget.items) {
        if (item['item']!.isNotEmpty && item['quantity']!.isNotEmpty) {
          await donationRef.collection('items').add({
            'itemName': item['item'],
            'quantity': int.tryParse(item['quantity']!) ?? 0,
          });
        }
      }

      // Pop to the previous screen or clear the form
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GenerateQr(donationId: newDonationId)))
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0.5, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Column(
                          children: [
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Color(0xFF015490),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Drop-off Point",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        location?['exactAdress'] ?? 'Loading location',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            color: Color(0xFF015490),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Goods List",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
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
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          SizedBox(
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
          if (_isLoading)
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 56,
              color: Colors.black.withOpacity(0.5),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
