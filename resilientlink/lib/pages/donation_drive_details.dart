import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resilientlink/pages/map.dart';

class DonationDriveDetails extends StatefulWidget {
  final String donationId;
  const DonationDriveDetails({super.key, required this.donationId});

  @override
  State<DonationDriveDetails> createState() => _DonationDriveDetailsState();
}

class _DonationDriveDetailsState extends State<DonationDriveDetails> {
  // To store the fetched donation data
  Map<String, dynamic>? donationDrive;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDonationDetails();
    _requestLocationPermission();
  }

  Future<void> _fetchDonationDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(widget.donationId)
          .get();

      if (doc.exists) {
        setState(() {
          donationDrive = doc.data() as Map<String, dynamic>? ?? {};
          isLoading = false;
        });
      } else {
        setState(() {
          donationDrive = {};
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        donationDrive = {};
        isLoading = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      // Handle permission denial
    }
  }

  @override
  Widget build(BuildContext context) {
    final Timestamp? timestamp = donationDrive?['timestamp'] as Timestamp?;
    final DateTime? dateTime = timestamp?.toDate();
    final String formattedDate = dateTime != null
        ? DateFormat('MMMM dd, yyyy – hh:mm a').format(dateTime)
        : 'Unknown date';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200.0),
        child: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          flexibleSpace: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Stack(
              children: [
                isLoading
                    ? const SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: donationDrive?['image'] != null
                            ? Image.network(
                                donationDrive!['image'] as String,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: progress.expectedTotalBytes !=
                                                null
                                            ? progress.cumulativeBytesLoaded /
                                                (progress.expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    );
                                  }
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : const SizedBox(
                                height: 250,
                              ),
                      ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    donationDrive?['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
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
                  top: 45,
                  right: 24,
                  child: Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PROPONENT: ${donationDrive?['proponent'] ?? 'Unknown'}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(formattedDate),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        donationDrive?['isAid']
                            ? const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Packs Shared",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  SizedBox(height: 14),
                                  Text(
                                    "100,00",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              )
                            : const SizedBox.shrink(),
                        donationDrive?['isMonetary']
                            ? const Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Latest Donation",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  SizedBox(height: 14),
                                  Text(
                                    "₱100,00",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    donationDrive?['isAid']
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 219, 235, 248),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: .5,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "NEEDED RESOURCES",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(donationDrive?['itemsNeeded'] ??
                                    'No items needed')
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 15),
                    const Text(
                      "PURPOSE",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(donationDrive?['purpose'] ?? 'No purpose provided'),
                    const SizedBox(height: 15),
                    donationDrive?['isAid']
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Drop Off Points",
                                style: TextStyle(fontSize: 16),
                              ),
                              Container(
                                height: 300,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Maps(
                                  donationId: widget.donationId,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 70)
                  ],
                ),
              ),
            ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: const Color(0xFF015490),
          label: const Text(
            "Donate now",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
