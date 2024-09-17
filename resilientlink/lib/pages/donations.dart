import 'package:flutter/material.dart';
import 'package:resilientlink/outputs/current_donation_drive.dart';
import 'package:resilientlink/outputs/ended_donation_drive.dart';

class Donations extends StatefulWidget {
  const Donations({super.key});

  @override
  State<Donations> createState() => _DonationsState();
}

class _DonationsState extends State<Donations> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Call for Donations",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "The Provincial Disaster Risk Reduction and Management Office delivers all the proceeds",
                    style: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                ],
              ),
            ),
            CurrentDonationDrive(),
            EndedDonationDrive()
          ],
        ),
      ),
    );
  }
}
