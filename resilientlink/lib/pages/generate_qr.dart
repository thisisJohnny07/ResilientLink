import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:resilientlink/pages/ongoing_donation.dart';

class GenerateQr extends StatefulWidget {
  final String donationId;
  const GenerateQr({super.key, required this.donationId});

  @override
  State<GenerateQr> createState() => _GenerateqrState();
}

class _GenerateqrState extends State<GenerateQr> {
  late TextEditingController donationIdController;
  String data = '';
  final GlobalKey _qrkey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/storage/emulated/0/Download/Qr_code';

  @override
  void initState() {
    super.initState();
    donationIdController = TextEditingController(text: widget.donationId);
  }

  Future<Uint8List?> _generateQrImage() async {
    try {
      RenderRepaintBoundary boundary =
          _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);

      // Drawing White Background because QR Code is Black
      final Rect bounds =
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      final Paint gradientPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Color(0xFF428CD4),
            Color(0xFF015490),
            Color(0xFF428CD4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
      canvas.drawRect(
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          gradientPaint);
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print('Error generating QR image: $e');
      return null;
    }
  }

  Future<void> _uploadQrCodeToFirebase() async {
    try {
      Uint8List? pngBytes = await _generateQrImage();
      if (pngBytes == null) return;

      String filename = DateTime.now().microsecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDireImages = referenceRoot.child('QR_Codes');
      Reference referenceImageToUpload = referenceDireImages.child(filename);

      await referenceImageToUpload.putData(
        pngBytes,
        SettableMetadata(
          contentType: 'image/png',
        ),
      );

      // Get the download URL for the uploaded image
      String imageUrl = await referenceImageToUpload.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('aid_donation')
          .doc(widget.donationId)
          .set({
        'qrCode': imageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _captureAndSavePng() async {
    try {
      Uint8List? pngBytes = await _generateQrImage();
      if (pngBytes == null) return;

      // Check for duplicate file name to avoid Override
      String fileName = 'qr_code';
      int i = 1;
      while (await File('$externalDir/$fileName.png').exists()) {
        fileName = 'qr_code_$i';
        i++;
      }

      // Check if Directory Path exists or not
      dirExists = await Directory(externalDir).exists();
      // If not then create the path
      if (!dirExists) {
        await Directory(externalDir).create(recursive: true);
        dirExists = true;
      }

      final file = await File('$externalDir/$fileName.png').create();
      await file.writeAsBytes(pngBytes);

      const snackBar = SnackBar(
          content: Text('QR code saved to gallery'),
          duration: Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      const snackBar = SnackBar(content: Text('Something went wrong!!!'));
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
                          const Text(
                            "Thank you for helping us build resilience!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
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
                            child: RepaintBoundary(
                              key: _qrkey,
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
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor:
                                  Color.fromARGB(255, 219, 235, 248),
                            ),
                            onPressed: _captureAndSavePng,
                            child: Text("Dowload QR Code"),
                          )
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
              _uploadQrCodeToFirebase();
              final route = MaterialPageRoute(
                builder: (context) => OngoingDonation(),
              );

              Navigator.pushAndRemoveUntil(context, route, (route) => false);
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
