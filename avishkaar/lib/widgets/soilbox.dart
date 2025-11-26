import 'package:flutter/material.dart';

class SoilBox extends StatelessWidget {
  final Map<String, dynamic>? soil;
  final bool loading;

  const SoilBox({super.key, required this.soil, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : soil == null
              ? const Text("No soil data available.")
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Soil Information",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("Moisture: ${soil?["moisture"]}%"),
                    Text("Soil Type: ${soil?["soil_type"]}"),
                    Text("Nitrogen (N): ${soil?["nitrogen"]}"),
                    Text("Phosphorus (P): ${soil?["phosphorus"]}"),
                    Text("Potassium (K): ${soil?["potassium"]}"),
                    Text("pH: ${soil?["ph"]}"),
                  ],
                ),
    );
  }
}
