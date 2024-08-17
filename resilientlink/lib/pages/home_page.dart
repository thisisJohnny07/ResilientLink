import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:resilientlink/models/weather_model.dart';
import 'package:resilientlink/services/weather_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _weatherServices = WeatherServices("bc0b23f74b8e3eefb32e919b460df7ae");
  Weather? _weather;

  _fetchWeather() async {
    String cityName = await _weatherServices.getCurrentCity();

    try {
      final weather = await _weatherServices.getWeather(cityName);
      setState(() {
        _weather = weather;
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_weather?.cityName ?? "loading city..."),
              Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
              Text("${_weather?.temperature.round()}°C"),
              Text(_weather?.mainCondition ?? "")
            ],
          ),
        ),
      ),
    );
  }
}
