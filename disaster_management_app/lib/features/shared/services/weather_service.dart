import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';

class WeatherService {
  final String apiKey = AppConstants.weatherApiKey;
  final String baseUrl = AppConstants.weatherBaseUrl;

  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> getForecast(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  Future<Map<String, dynamic>> searchLocation(String query) async {
    final response = await http.get(
      Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=1&appid=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      if (results.isNotEmpty) {
        return {
          'lat': results[0]['lat'],
          'lon': results[0]['lon'],
          'name': results[0]['name'],
          'country': results[0]['country'],
        };
      } else {
        throw Exception('Location not found');
      }
    } else {
      throw Exception('Failed to search location');
    }
  }

  String getWeatherIcon(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  Map<String, dynamic> processWeatherData(Map<String, dynamic> data) {
    return {
      'temperature': (data['main']['temp'] as num).toDouble(),
      'description': data['weather'][0]['description'] as String,
      'icon': getWeatherIcon(data['weather'][0]['icon']),
      'humidity': (data['main']['humidity'] as num).toDouble(),
      'windSpeed': (data['wind']['speed'] as num).toDouble(),
      'pressure': (data['main']['pressure'] as num).toDouble(),
      'feelsLike': (data['main']['feels_like'] as num).toDouble(),
    };
  }

  List<Map<String, dynamic>> processForecastData(Map<String, dynamic> data) {
    final List<dynamic> list = data['list'];
    final List<Map<String, dynamic>> forecast = [];

    // Get current date to determine the starting point
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    // Create a map to organize data by date and time
    final Map<String, Map<String, List<dynamic>>> forecastByDate = {};

    // Process all forecasts and organize by date
    for (var item in list) {
      final DateTime date =
          DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);

      // Skip data from the current day
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        continue;
      }

      // Format day as YYYY-MM-DD
      final String dayKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      if (!forecastByDate.containsKey(dayKey)) {
        forecastByDate[dayKey] = {
          'morning': [],
          'evening': [],
        };
      }

      // Check if this forecast is for morning (around 8 AM) or evening (around 5 PM)
      if (date.hour >= 6 && date.hour <= 10) {
        forecastByDate[dayKey]!['morning']!.add(item);
      } else if (date.hour >= 16 && date.hour <= 20) {
        forecastByDate[dayKey]!['evening']!.add(item);
      }
    }

    // Sort dates
    final sortedDates = forecastByDate.keys.toList()..sort();

    // Take only next 3 days
    for (var i = 0; i < sortedDates.length && i < 3; i++) {
      final date = sortedDates[i];
      final forecasts = forecastByDate[date]!;

      // Process morning forecast
      if (forecasts['morning']!.isNotEmpty) {
        final morningData = forecasts['morning']!.first;
        final forecastDate =
            DateTime.fromMillisecondsSinceEpoch(morningData['dt'] * 1000);

        forecast.add({
          'date': forecastDate,
          'temperature': (morningData['main']['temp'] as num).toDouble(),
          'description': morningData['weather'][0]['description'] as String,
          'icon': getWeatherIcon(morningData['weather'][0]['icon']),
          'humidity': (morningData['main']['humidity'] as num).toDouble(),
          'windSpeed': (morningData['wind']['speed'] as num).toDouble(),
          'time': 'morning',
        });
      }

      // Process evening forecast
      if (forecasts['evening']!.isNotEmpty) {
        final eveningData = forecasts['evening']!.first;
        final forecastDate =
            DateTime.fromMillisecondsSinceEpoch(eveningData['dt'] * 1000);

        forecast.add({
          'date': forecastDate,
          'temperature': (eveningData['main']['temp'] as num).toDouble(),
          'description': eveningData['weather'][0]['description'] as String,
          'icon': getWeatherIcon(eveningData['weather'][0]['icon']),
          'humidity': (eveningData['main']['humidity'] as num).toDouble(),
          'windSpeed': (eveningData['wind']['speed'] as num).toDouble(),
          'time': 'evening',
        });
      }
    }

    return forecast;
  }
}
