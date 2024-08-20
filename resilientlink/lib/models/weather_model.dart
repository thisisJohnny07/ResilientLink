class WeatherData {
  final String cityName;
  final double temperature;
  final String mainCondition;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
    );
  }
}
