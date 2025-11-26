import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const API_KEY = "f46948a9b0464bdc8da135934240611";

  static Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final url =
        "http://api.weatherapi.com/v1/current.json?key=$API_KEY&q=$lat,$lon&aqi=no";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception("Weather API failed: ${res.body}");
    }

    final data = json.decode(res.body);

    return {
      "temperature": data["current"]["temp_c"],
      "humidity": data["current"]["humidity"],
      "rainfall": data["current"]["precip_mm"],
      "condition": data["current"]["condition"]["text"],
    };
  }
}
