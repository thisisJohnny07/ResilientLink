import 'package:flutter/material.dart';
import 'package:resilientlink/pages/select_drop_off.dart';

class DonateAid extends StatefulWidget {
  final String donationId;
  const DonateAid({super.key, required this.donationId});

  @override
  State<DonateAid> createState() => _DonateAidState();
}

class _DonateAidState extends State<DonateAid> {
  List<Map<String, TextEditingController>> itemControllers = [];
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void initState() {
    super.initState();
    addItemFields();
  }

  void addItemFields() {
    setState(() {
      itemControllers.add({
        "item": TextEditingController(),
        "quantity": TextEditingController(),
      });
    });
  }

  @override
  void dispose() {
    for (var controller in itemControllers) {
      controller['item']?.dispose();
      controller['quantity']?.dispose();
    }
    super.dispose();
  }

  // Function to navigate to confirmation page
  void navigateToConfirmation() {
    if (_formKey.currentState?.validate() ?? false) {
      List<Map<String, String>> items = itemControllers.map((controller) {
        return {
          'item': controller['item']!.text.trim(),
          'quantity': controller['quantity']!.text.trim(),
        };
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectDropOff(
            items: items,
            donationId: widget.donationId,
          ),
        ),
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
        title: const Text("Aid/Relief Donation"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Attach the key to the form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Step 1:",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Fill up the Aid/Relief donation information",
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Item"),
                            Text("Quantity"),
                          ],
                        ),
                        ...itemControllers.map((controller) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: controller['item'],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Item cannot be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Flexible(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: controller['quantity'],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Quantity cannot be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: addItemFields,
                          icon: const Icon(Icons.add),
                          label: const Text("Add another item"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF015490),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: FloatingActionButton.extended(
          onPressed: navigateToConfirmation, // Navigate to confirmation page
          backgroundColor: const Color(0xFF015490),
          label: const Row(
            children: [
              Text(
                "Next",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 20),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              )
            ],
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
