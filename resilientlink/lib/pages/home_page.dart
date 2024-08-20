import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:resilientlink/models/weather_model.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _WeatherUpdates(),
              const SizedBox(
                height: 25,
              ),
              _buttons(),
              const SizedBox(
                height: 25,
              ),
              _advisories(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _WeatherUpdates() {
    return Center(
      child: Column(
        children: [
          Text(
            _weatherData?.cityName ?? "loading city...",
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
            ),
          ),
          Text(DateFormat('EEEE, d MMMM').format(DateTime.now())),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                    getWeatherAnimation(_weatherData?.mainCondition)),
              ),
              Container(
                height: 80,
                width: 1,
                color: Colors.black,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${_weatherData?.temperature.round() ?? "0"}°C",
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(_weatherData?.mainCondition ?? ""),
                ],
              ),
            ],
          ),
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5), bottomLeft: Radius.circular(5)),
              border: const Border(
                left: BorderSide(
                  color: Color(0xFF015490),
                  width: 5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0.5,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(2) ?? "0"} °C",
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    Text(
                      "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(2) ?? "0"} °C",
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Wind: ${_weather?.windSpeed?.toStringAsFixed(2) ?? "0"} m/s",
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    Text(
                      "Humidity: ${_weather?.humidity?.toStringAsFixed(2) ?? "0"} %",
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

// Three Buttons
  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.phone,
                    color: Color(0xFF011222),
                    size: 50,
                  ),
                  Text(
                    "Hotlines",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.volunteer_activism,
                    color: Color(0xFF011222),
                    size: 50,
                  ),
                  Text(
                    "Donate",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.directions_run,
                    color: Color(0xFF011222),
                    size: 50,
                  ),
                  Text(
                    "Evacuation",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _advisories() {
    return Row(
      children: [
        const Text(
          "Advisories",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Container(
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF015490),
            ),
          ),
        ),
      ],
    );
  }
}
