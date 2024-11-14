import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlink/Widget/dialog_box.dart';

class Advisories extends StatefulWidget {
  const Advisories({super.key});

  @override
  State<Advisories> createState() => _AdvisoriesState();
}

class _AdvisoriesState extends State<Advisories> {
  final CollectionReference advisories =
      FirebaseFirestore.instance.collection("advisory");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF015490),
        foregroundColor: Colors.white,
        title: const Text("Advisories"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: advisories.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (snapshot.hasData) {
                      QuerySnapshot querySnapshot = snapshot.data!;
                      List<QueryDocumentSnapshot> document = querySnapshot.docs;

                      if (document.isEmpty) {
                        return const Center(
                          child: Text('No advisory posted'),
                        );
                      }

                      List<Map<String, dynamic>> items = document
                          .map((e) => e.data() as Map<String, dynamic>)
                          .toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic> advisory = items[index];

                          final Timestamp? timestamp =
                              advisory['timestamp'] as Timestamp?;
                          final DateTime? dateTime = timestamp?.toDate();
                          final String formattedDate = dateTime != null
                              ? DateFormat('MMMM dd, yyyy – hh:mm a')
                                  .format(dateTime)
                              : 'Unknown date';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        bottom: 5,
                                        top: 5),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.campaign,
                                          color: Color(0xFF015490),
                                          size: 40,
                                        ),
                                        const SizedBox(width: 5),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              advisory['title'] ?? 'No Title',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  height: 1),
                                            ),
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  advisory['image'] != null &&
                                          advisory['image'].isNotEmpty
                                      ? Image.network(advisory['image'])
                                      : const SizedBox.shrink(),
                                  const SizedBox(height: 5),
                                  Material(
                                    color: Colors.white,
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return DialogBox(
                                                title: advisory['title'],
                                                date: formattedDate,
                                                image: advisory['image'],
                                                details: advisory['details'],
                                                weatherSystem:
                                                    advisory['weatherSystem'],
                                                hazards: advisory['hazards'],
                                                precautions:
                                                    advisory['precautions'],
                                              );
                                            });
                                      },
                                      child: const Text(
                                        "View Details",
                                        style:
                                            TextStyle(color: Color(0xFF015490)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    // Default case when no data and no error
                    return const Center(
                      child: Text('No advisory posted'),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
