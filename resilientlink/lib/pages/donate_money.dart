import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resilientlink/pages/customer_paymongo_screen.dart';
import 'package:resilientlink/services/paymongo_service.dart';

class DonateMoney extends StatefulWidget {
  final String donationDriveId;
  const DonateMoney({super.key, required this.donationDriveId});

  @override
  State<DonateMoney> createState() => _DonateMoneyState();
}

class _DonateMoneyState extends State<DonateMoney> {
  TextEditingController phone = TextEditingController();
  TextEditingController amount = TextEditingController();
  PaymongoService _paymongoService = PaymongoService();
  int? selectedOption;

  // Function to check if both text fields are filled and an option is selected
  bool get _isFormValid {
    return phone.text.isNotEmpty &&
        amount.text.isNotEmpty &&
        selectedOption != null;
  }

  void createPayment() async {
    String modeOfPayment = '';
    if (selectedOption == 1) {
      modeOfPayment = "card";
    } else if (selectedOption == 2) {
      modeOfPayment = "gcash";
    } else if (selectedOption == 3) {
      modeOfPayment = "paymaya";
    }
    Map<String, dynamic> res = await _paymongoService.createPayment(
      description: "Test description",
      billingName: "${FirebaseAuth.instance.currentUser!.displayName}",
      billingEmail: "${FirebaseAuth.instance.currentUser!.email}",
      billingPhone: phone.text,
      lineItemAmount: double.parse(amount.text),
      lineItemName: "Donation",
      lineItemQuantity: 1,
      currency: "PHP",
      paymentMethod: modeOfPayment,
    );
    if (res['success']) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CustomerPaymongoScreen(
          checkoutUrl: res['data']['checkout_url'],
          donationDriveId: widget.donationDriveId,
          donorId: "${FirebaseAuth.instance.currentUser!.uid}",
          amount: double.parse(amount.text),
          modeOfPayment: modeOfPayment,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF015490),
        foregroundColor: Colors.white,
        title: const Text("Money Donation"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Please complete all required fields.",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text("Phone number"),
                SizedBox(height: 5),
                TextFormField(
                  controller: phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      setState(() {}), // Trigger re-build when text changes
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text("Amount"),
                SizedBox(height: 5),
                TextFormField(
                  controller: amount,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      setState(() {}), // Trigger re-build when text changes
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text("Fund Transfer Method"),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = 1;
                    });
                  },
                  child: Option(
                    imageAsset:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHg6L0yf2DhQrkSIGWp0BnADyYi5OkOI2MPA&s',
                    header: "Card",
                    isSelected: selectedOption == 1,
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = 2;
                    });
                  },
                  child: Option(
                    imageAsset:
                        'https://play-lh.googleusercontent.com/QNP0Aj2hyumAmYiWVAsJtY2LLTQnzHxdW7-DpwFUFNkPJjgRxi-BXg7A4yI6tgYKMeU',
                    header: "GCash",
                    isSelected: selectedOption == 2,
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = 3;
                    });
                  },
                  child: Option(
                    imageAsset:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZdGTop-kUyDci9KuNnZLLwTz3mYY0-Nh6ew&s',
                    header: "Paymaya",
                    isSelected: selectedOption == 3,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
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
                  onPressed: _isFormValid
                      ? createPayment
                      : null, // Disable button if form is invalid
                  child: const Text("Confirm"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Option extends StatelessWidget {
  final String imageAsset;
  final String header;
  final bool isSelected;

  const Option({
    super.key,
    required this.imageAsset,
    required this.header,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  imageAsset,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 15),
            Text(
              header,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
