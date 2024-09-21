import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:resilientlink/pages/bottom_navigation.dart';

class GenerateQr extends StatefulWidget {
  final String donationId;
  const GenerateQr({super.key, required this.donationId});

  @override
  State<GenerateQr> createState() => _GenerateqrState();
}

class _GenerateqrState extends State<GenerateQr> {
  late TextEditingController donationIdController;

  @override
  void initState() {
    super.initState();
    donationIdController = TextEditingController(text: widget.donationId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Returning false will prevent the back button from functioning
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF015490),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            donationIdController.text.isEmpty
                ? Container()
                : Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Thank you",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF428CD4),
                                Color(0xFF015490),
                                Color(0xFF428CD4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: QrImageView(
                              data: donationIdController.text,
                              version: QrVersions.auto,
                              size: 200,
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.white,
                              ),
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {}, child: Text("Dowload QR Code"))
                        ],
                      ),
                    ),
                  ),
          ],
        ),
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavigation(),
                ),
              );
            },
            backgroundColor: Colors.white,
            label: Row(
              children: [
                const Text(
                  "Finish",
                  style: TextStyle(color: Color(0xFF015490)),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.task_alt,
                  color: Color(0xFF015490),
                ),
              ],
            ),
            elevation: 0,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
