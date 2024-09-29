import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Items extends StatefulWidget {
  final String donationId;

  const Items({super.key, required this.donationId});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  // To store the fetched donation data
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDonationDetails();
  }

  Future<void> _fetchDonationDetails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('aid_donation')
          .doc(widget.donationId)
          .collection('items')
          .get();

      setState(() {
        items = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print(e); // Print error to console for debugging
      setState(() {
        items = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No items available',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.inventory_2,
              size: 18,
              color: Color(0xFF015490),
            ),
            SizedBox(width: 5),
            Text(
              "Aid/Relief Pack Inventory",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Item",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Quantity",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        ...items.map((item) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['itemName'] ?? 'Unknown Item',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text("${item['quantity'] ?? 0}"),
            ],
          );
        }).toList(),
      ],
    );
  }
}
