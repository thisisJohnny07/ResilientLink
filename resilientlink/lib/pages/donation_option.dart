import 'package:flutter/material.dart';
import 'package:resilientlink/pages/donate_aid.dart';
import 'package:resilientlink/pages/profile.dart';

class DonationOption extends StatefulWidget {
  final String donationId;
  const DonationOption({super.key, required this.donationId});

  @override
  State<DonationOption> createState() => _DonationOptionState();
}

class _DonationOptionState extends State<DonationOption> {
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF015490),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Donation Option"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What would you like to do?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Don't worry, you can make multiple donations",
                style: TextStyle(fontSize: 14, color: Colors.black38),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = 1;
                  });
                },
                child: Option(
                  imageAsset: 'images/aid.png',
                  header: "Aid/Relief Donation",
                  detail: "To be dropped at the designated point",
                  isSelected: selectedOption == 1,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = 2;
                  });
                },
                child: Option(
                  imageAsset: 'images/money.png',
                  header: "Monetary Donation",
                  detail: "Cash donations via PayMongo",
                  isSelected: selectedOption == 2,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF015490),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black,
                  ),
                  onPressed: selectedOption != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => selectedOption == 1
                                  ? DonateAid(
                                      donationId: widget.donationId,
                                    )
                                  : const Profile(),
                            ),
                          );
                        }
                      : null,
                  child: const Text("Confirm"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Option extends StatelessWidget {
  final String imageAsset;
  final String header;
  final String detail;
  final bool isSelected;

  const Option({
    super.key,
    required this.imageAsset,
    required this.header,
    required this.detail,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF015490) : Colors.black12,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                imageAsset,
                height: 150,
              ),
            ),
            Text(
              header,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(detail),
          ],
        ),
      ),
    );
  }
}
