import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MovDialogBox extends StatefulWidget {
  final String donationDriveId;
  const MovDialogBox({super.key, required this.donationDriveId});

  @override
  State<MovDialogBox> createState() => _MovDialogBoxState();
}

class _MovDialogBoxState extends State<MovDialogBox> {
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMov();
  }

  Future<void> _fetchMov() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('movs')
          .where('donationDriveId', isEqualTo: widget.donationDriveId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there is only one document with the matching donationDriveId
        setState(() {
          imageUrl = querySnapshot.docs.first['image'];
          isLoading = false;
        });
      } else {
        setState(() {
          imageUrl = null; // No document found
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        imageUrl = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: isLoading
          ? Center(
              child: const CircularProgressIndicator(),
            )
          : imageUrl != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    Image.network(
                      imageUrl!,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              : const Text(
                  'No image available'), // Show this if there's no image
    );
  }
}
