import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final String title;
  final String date;
  final String image;
  final String details;
  final String weatherSystem;
  final String hazards;
  final String precautions;

  const DialogBox({
    super.key,
    required this.title,
    required this.date,
    required this.image,
    required this.details,
    required this.weatherSystem,
    required this.hazards,
    required this.precautions,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SingleChildScrollView(
        child: Container(
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding:
              const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.campaign,
                    color: Color(0xFF015490),
                    size: 50,
                  ),
                  Text(
                    title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, height: 1),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                        color: Colors.black.withOpacity(.5), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Weather System:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    weatherSystem,
                  ),
                  const SizedBox(height: 5),
                  hazards.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Hazards:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              hazards,
                            ),
                            const SizedBox(height: 5),
                          ],
                        )
                      : const SizedBox.shrink(),
                  precautions.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Precautionary Measures:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              precautions,
                            ),
                            const SizedBox(height: 5),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
