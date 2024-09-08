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
          padding: const EdgeInsets.only(bottom: 5, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.campaign,
                    color: Color(0xFF015490),
                    size: 40,
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, height: 1),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                            color: Colors.black.withOpacity(.5), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              image.isNotEmpty
                  ? Image.network(
                      image,
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Weather System:",
                    style: TextStyle(
                      color: Colors.black.withOpacity(.5),
                    ),
                  ),
                  Text(
                    weatherSystem,
                  ),
                  const SizedBox(height: 5),
                  hazards.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hazards:",
                              style: TextStyle(
                                color: Colors.black.withOpacity(.5),
                              ),
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
                            Text(
                              "Precautionary Measures:",
                              style: TextStyle(
                                color: Colors.black.withOpacity(.5),
                              ),
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
