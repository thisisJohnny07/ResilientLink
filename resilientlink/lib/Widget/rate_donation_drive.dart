import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:resilientlink/pages/ratings.dart';

class RateDonationDrive extends StatefulWidget {
  final String donationDriveId;

  const RateDonationDrive({
    super.key,
    required this.donationDriveId,
  });

  @override
  State<RateDonationDrive> createState() => _RateDonationDriveState();
}

class _RateDonationDriveState extends State<RateDonationDrive> {
  Map<String, dynamic>? donationDrive;
  TextEditingController feedbackController = TextEditingController();
  bool hasError = false;
  int selectedRating = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDonationDrive();
  }

  Future<void> _fetchDonationDrive() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(widget.donationDriveId)
          .get();

      if (doc.exists) {
        setState(() {
          donationDrive = doc.data() as Map<String, dynamic>? ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          donationDrive = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        donationDrive = {};
        _isLoading = false;
      });
    }
  }

  // Submit feedback and generate certificate
  Future<void> submitFeedbackAndGenerateCertificate() async {
    setState(() {
      _isLoading = true;
    });
    if (feedbackController.text.isEmpty || selectedRating == 0) {
      setState(() {
        hasError = true;
        _isLoading = false;
      });
      return;
    }

    try {
      // Submit feedback to Firestore
      await FirebaseFirestore.instance.collection('ratings').add({
        'donationDriveId': widget.donationDriveId,
        'feedback': feedbackController.text,
        'rating': selectedRating,
        'donorId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mark the donation drive as rated
      await FirebaseFirestore.instance
          .collection('aid_donation')
          .where('donationDriveId', isEqualTo: widget.donationDriveId)
          .where('donorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.update({'isRated': true});
        }
      });

      // Mark the donation drive as rated
      await FirebaseFirestore.instance
          .collection('money_donation')
          .where('donationDriveId', isEqualTo: widget.donationDriveId)
          .where('donorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.update({'isRated': true});
        }
      });

      // Generate certificate after feedback submission
      User? user = FirebaseAuth.instance.currentUser;
      await createCertificate(user?.displayName ?? 'Donor');

      // Close the dialog after certificate generation
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Ratings()));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  // Load image for the certificate
  Future<Uint8List> _loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  // Create certificate PDF
  Future<void> createCertificate(String userName) async {
    const borderColor = PdfColor(1 / 255, 84 / 255, 144 / 255);
    final imageBytes = await _loadImage('images/pdrrmo.png');
    final image = pw.MemoryImage(imageBytes);
    final imageBytes2 = await _loadImage('images/southcotabato.png');
    final image2 = pw.MemoryImage(imageBytes2);
    final imageBytes3 = await _loadImage('images/signature.png');
    final image3 = pw.MemoryImage(imageBytes3);

    DateTime date = donationDrive?['timestamp'].toDate();
    String formattedDate = DateFormat('MMMM d, y').format(date);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.SizedBox.expand(
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: borderColor,
                  width: 1,
                ),
              ),
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Image(image, height: 50),
                      pw.SizedBox(width: 40),
                      pw.Column(
                        children: [
                          pw.Text(
                            'Provincial Disaster Risk Reduction and Management Office',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text('Zone 4, Poblacion',
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.Text('Koronadal City, South Cotabato',
                              style: const pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                      pw.SizedBox(width: 40),
                      pw.Image(image2, height: 50),
                    ],
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text('CERTIFICATE',
                      style: const pw.TextStyle(fontSize: 40)),
                  pw.Text('OF APPRECIATION',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.SizedBox(height: 20),
                  pw.Text('This Certificate is Proudly Presented to',
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 20, horizontal: 150),
                    child: pw.Column(children: [
                      pw.Text(userName,
                          style: const pw.TextStyle(fontSize: 30)),
                      pw.Divider(),
                    ]),
                  ),
                  pw.Text(
                    'In grateful recognition of your generous support during the donation drive for the victims of ${donationDrive?['title']} on $formattedDate.\n'
                    'Your kindness has brought hope and resilience to those in need, making a meaningful impact on the community.',
                    style: const pw.TextStyle(fontSize: 12),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 30),
                  pw.Image(image3, height: 50),
                  pw.Text('Mr. Rolly Doane C. Aquino, RN, MPA, MMNSA',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                      ),
                      textAlign: pw.TextAlign.center),
                  pw.Text('LDRRMO IV/OIC-PDRRMO South Cotabato',
                      style: const pw.TextStyle(fontSize: 12),
                      textAlign: pw.TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );

    Uint8List pdfInBytes = await pdf.save();
    await uploadPDFToStorage(
        pdfInBytes, FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> uploadPDFToStorage(Uint8List pdfInBytes, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'certificates/certificate_${userId}_${DateTime.now().millisecondsSinceEpoch}.pdf');

      final uploadTask = storageRef.putData(pdfInBytes);
      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();

      await saveDownloadURLToFirestore(downloadURL, userId);
    } catch (e) {
      print('Error uploading PDF: $e');
    }
  }

  Future<void> saveDownloadURLToFirestore(
      String downloadURL, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('E-Certificates').add({
        'ECertificate': downloadURL,
        'donationDriveId': widget.donationDriveId, // Corrected reference
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving URL to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(color: Color(0xFF015490)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                donationDrive!['title'] ?? 'No Title Available',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text("Rating"),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    icon: Icon(
                                      index < selectedRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 30,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedRating = index + 1;
                                        hasError =
                                            false; // Reset error on valid rating
                                      });
                                    },
                                  );
                                }),
                              ),
                              if (hasError && selectedRating == 0)
                                Text(
                                  'Please select a rating',
                                  style: TextStyle(color: Colors.red),
                                ),
                              SizedBox(height: 10),
                              Text("Feedbacks"),
                              SizedBox(height: 5),
                              TextField(
                                controller: feedbackController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  errorText: hasError &&
                                          feedbackController.text.isEmpty
                                      ? 'Please enter feedback'
                                      : null,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0, vertical: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF015490),
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 2,
                                    shadowColor: Colors.black,
                                  ),
                                  onPressed:
                                      submitFeedbackAndGenerateCertificate,
                                  child: const Text('Submit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
