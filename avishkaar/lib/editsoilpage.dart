import 'package:avishkaar/services/soil_service.dart';
import 'package:flutter/material.dart';
// import '../services/firebase_soil_service.dart';

class EditSoilPage extends StatefulWidget {
  final String uid;
  final Map<String, dynamic>? existingSoil;

  const EditSoilPage({super.key, required this.uid, this.existingSoil});

  @override
  State<EditSoilPage> createState() => _EditSoilPageState();
}

class _EditSoilPageState extends State<EditSoilPage> {
  final moisture = TextEditingController();
  final soilType = TextEditingController();
  final nitrogen = TextEditingController();
  final phosphorus = TextEditingController();
  final potassium = TextEditingController();
  final ph = TextEditingController();
  final cropType = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingSoil != null) {
      moisture.text = widget.existingSoil!["moisture"]?.toString() ?? "";
      soilType.text = widget.existingSoil!["soil_type"]?.toString() ?? "";
      nitrogen.text = widget.existingSoil!["nitrogen"]?.toString() ?? "";
      phosphorus.text = widget.existingSoil!["phosphorus"]?.toString() ?? "";
      potassium.text = widget.existingSoil!["potassium"]?.toString() ?? "";
      ph.text = widget.existingSoil!["ph"]?.toString() ?? "";
      cropType.text = widget.existingSoil!["crop_type"]?.toString() ?? "";
    }
  }

  Future<void> save() async {
    await FirebaseSoilService.updateSoilProfile(widget.uid, {
      "moisture": double.tryParse(moisture.text),
      "soil_type": int.tryParse(soilType.text),
      "nitrogen": double.tryParse(nitrogen.text),
      "phosphorus": double.tryParse(phosphorus.text),
      "potassium": double.tryParse(potassium.text),
      "ph": double.tryParse(ph.text),
      "crop_type": int.tryParse(cropType.text),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Soil Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: moisture, decoration: const InputDecoration(labelText: "Moisture (%)")),
            TextField(controller: soilType, decoration: const InputDecoration(labelText: "Soil Type")),
            TextField(controller: nitrogen, decoration: const InputDecoration(labelText: "Nitrogen")),
            TextField(controller: phosphorus, decoration: const InputDecoration(labelText: "Phosphorus")),
            TextField(controller: potassium, decoration: const InputDecoration(labelText: "Potassium")),
            TextField(controller: ph, decoration: const InputDecoration(labelText: "pH")),
            TextField(controller: cropType, decoration: const InputDecoration(labelText: "Crop Type ID")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
