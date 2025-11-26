import 'package:flutter/material.dart';

class WeatherBox extends StatelessWidget {
  final Map<String, dynamic>? weather;
  final bool loading;

  const WeatherBox({super.key, required this.weather, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weather Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Temperature: ${weather?["temperature"]}°C"),
                Text("Humidity: ${weather?["humidity"]}%"),
                Text("Rainfall: ${weather?["rainfall"]} mm"),
                Text("Condition: ${weather?["condition"]}"),
              ],
            ),
    );
  }
}
