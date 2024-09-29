import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package

class QrDialogBox extends StatelessWidget {
  final String image;

  const QrDialogBox({super.key, required this.image});

  Future<void> _captureAndSavePng(BuildContext context) async {
    try {
      // Fetch the image bytes from the network
      http.Response response = await http.get(Uri.parse(image));
      if (response.statusCode != 200) return;

      Uint8List pngBytes = response.bodyBytes;

      // Set the external directory path (you may need permission for this on Android)
      String externalDir = '/storage/emulated/0/Download/Qr_code';

      // Check for duplicate file names to avoid override
      String fileName = 'qr_code';
      int i = 1;
      while (await File('$externalDir/$fileName.png').exists()) {
        fileName = 'qr_code_$i';
        i++;
      }

      // Check if directory exists or create it
      bool dirExists = await Directory(externalDir).exists();
      if (!dirExists) {
        await Directory(externalDir).create(recursive: true);
      }

      // Save the file
      final file = await File('$externalDir/$fileName.png').create();
      await file.writeAsBytes(pngBytes);

      // Show success message
      const snackBar = SnackBar(
        content: Text('QR code saved to gallery'),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      // Show error message
      const snackBar = SnackBar(content: Text('Something went wrong!!!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(image),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color.fromARGB(255, 219, 235, 248),
            ),
            onPressed: () async {
              await _captureAndSavePng(context);
              Navigator.pop(context);
            },
            child: const Text("Download QR Code"),
          ),
        ],
      ),
    );
  }
}
