import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:resilientlink/Widget/button.dart';
import 'package:resilientlink/Widget/dialog_box.dart';
import 'package:resilientlink/Widget/weather_info.dart';
import 'package:resilientlink/models/weather_model.dart';
import 'package:resilientlink/pages/messages.dart';
import 'package:resilientlink/services/weather_services.dart';
import 'package:weather/weather.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _weatherServices = WeatherServices("bc0b23f74b8e3eefb32e919b460df7ae");
  WeatherData? _weatherData;
  final WeatherFactory _wf = WeatherFactory("bc0b23f74b8e3eefb32e919b460df7ae");
  Weather? _weather;

  _fetchWeather() async {
    String cityName = await _weatherServices.getCurrentCity();

    try {
      final weatherData = await _weatherServices.getWeather(cityName);
      setState(() {
        _weatherData = weatherData;
      });
      _wf.currentWeatherByCityName(cityName).then((w) {
        setState(() {
          _weather = w;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sun.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sun.json';
      default:
        return 'assets/sun.json';
    }
  }

  final CollectionReference advisories =
      FirebaseFirestore.instance.collection("advisory");

  @override
  void initState() {
    super.initState();

    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
          child: Image.asset(
            'images/logo.png',
            height: 40,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail),
            color: const Color(0xFF015490),
            onPressed: () async {
              try {
                // Fetch the admin data using a query (assuming there's only one admin)
                var adminQuery = await FirebaseFirestore.instance
                    .collection('admin')
                    .where('isAdmin',
                        isEqualTo: true) // Fetch the admin dynamically
                    .limit(1) // Limit to one admin, in case there are more
                    .get();

                if (adminQuery.docs.isNotEmpty) {
                  var adminData = adminQuery.docs.first.data();

                  // Assuming adminData contains 'email' and 'uid' fields
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Messages(
                        recieverEmail: adminData['email'],
                        recieverID: adminData['uid'],
                      ),
                    ),
                  );
                }
              } catch (e) {
                print(e);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _WeatherUpdates(),
                    const SizedBox(
                      height: 25,
                    ),
                    _buttons(),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                )),
            _advisories(),
          ],
        ),
      ),
    );
  }

  Widget _WeatherUpdates() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF015490),
                Color(0xFF428CD4),
                Color(0xFF015490),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  Text(
                    _weatherData?.cityName ?? "loading city...",
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ],
              ),
              Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: const TextStyle(color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Lottie.asset(
                        getWeatherAnimation(_weatherData?.mainCondition)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${_weatherData?.temperature.round() ?? "0"}°",
                        style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(_weatherData?.mainCondition ?? "",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WeatherInfo(
                      icon: Icons.thermostat,
                      label: "Pressure",
                      data:
                          "${_weather?.pressure?.toStringAsFixed(0) ?? "0"}hPa",
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    WeatherInfo(
                        icon: Icons.water_drop,
                        label: "Humidity",
                        data:
                            "${_weather?.humidity?.toStringAsFixed(0) ?? "0"}%"),
                    const SizedBox(
                      width: 20,
                    ),
                    WeatherInfo(
                      icon: Icons.air,
                      label: "Wind",
                      data:
                          "${_weather?.windSpeed?.toStringAsFixed(2) ?? "0"}m/s",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Three Buttons
  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Button(
            onTab: () {},
            label: "Hotlines",
            icon: Icons.phone,
          ),
          const SizedBox(
            width: 20,
          ),
          Button(
            onTab: () {},
            label: "Evacuation",
            icon: Icons.directions_run,
          )
        ],
      ),
    );
  }

  Widget _advisories() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16, top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(),
                Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      color: Color(0xFF015490),
                    ),
                    Text(
                      "Advisories",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: advisories.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        ? DateFormat('MMMM dd, yyyy – hh:mm a').format(dateTime)
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
                                  left: 16.0, right: 16.0, bottom: 5, top: 5),
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
                                          color: Colors.black.withOpacity(.5),
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
                                          precautions: advisory['precautions'],
                                        );
                                      });
                                },
                                child: const Text(
                                  "View Details",
                                  style: TextStyle(color: Color(0xFF015490)),
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
    );
  }
}
