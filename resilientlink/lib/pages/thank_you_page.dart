import 'package:flutter/material.dart';
import 'package:resilientlink/pages/ongoing_donation.dart';

class ThankYouPage extends StatelessWidget {
  final int index;
  const ThankYouPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 3), // Adjust spacing to shift content upwards
              Image.asset(
                "images/truck.png",
                height: 200,
              ),
              SizedBox(height: 20),
              Text(
                "Thank You!",
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF015490),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Together, we make a difference. Keep supporting our journey toward resilience.",
                textAlign: TextAlign.center,
              ),
              Spacer(flex: 4), // More space at bottom to offset the button area
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OngoingDonation(initialTabIndex: index),
              ),
            );
          },
          backgroundColor: Color(0xFF015490),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Proceed",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ],
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
