import 'package:avishkaar/constants/locationhelper.dart';
import 'package:avishkaar/editsoilpage.dart';
import 'package:avishkaar/services/soil_service.dart';
import 'package:avishkaar/widgets/soilbox.dart';
import 'package:avishkaar/widgets/weatherbox.dart';
import 'package:flutter/material.dart';
import '../services/weather_service.dart';
// import '../utils/location_helper.dart';

class FarmerDashboard extends StatefulWidget {
  final String uid;

  const FarmerDashboard({super.key, required this.uid});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  Map<String, dynamic>? weather;
  Map<String, dynamic>? soil;

  bool loadingWeather = true;
  bool loadingSoil = true;
  String? weatherError;

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    await fetchWeather();
    await fetchSoil();
  }

  /// ----------------------------------------------------
  /// WEATHER FETCH USING LOCATION HELPER
  /// ----------------------------------------------------
  Future<void> fetchWeather() async {
    setState(() {
      loadingWeather = true;
      weatherError = null;
    });

    try {
      final position = await LocationHelper.getLocation();

      if (position == null) {
        setState(() {
          loadingWeather = false;
          weatherError = "Unable to fetch location. Enable GPS and try again.";
        });
        return;
      }

      final data = await WeatherService.getWeather(
        position.latitude,
        position.longitude,
      );

      setState(() {
        weather = data;
        loadingWeather = false;
      });
    } catch (e) {
      setState(() {
        loadingWeather = false;
        weatherError = "Failed to fetch weather: $e";
      });
    }
  }

  /// ----------------------------------------------------
  /// FETCH SOIL DETAILS FROM FIREBASE
  /// ----------------------------------------------------
  Future<void> fetchSoil() async {
    try {
      final soilData = await FirebaseSoilService.getSoilProfile(widget.uid);
      setState(() {
        soil = soilData;
        loadingSoil = false;
      });
    } catch (e) {
      print("Soil error: $e");
      setState(() => loadingSoil = false);
    }
  }

  /// ----------------------------------------------------
  /// MAIN UI
  /// ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Dashboard"),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: fetchDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // WEATHER UI
              if (weatherError != null)
                Column(
                  children: [
                    Text(
                      weatherError!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: fetchWeather,
                      child: const Text("Retry Weather Fetch"),
                    ),
                  ],
                )
              else
                WeatherBox(weather: weather, loading: loadingWeather),

              const SizedBox(height: 20),

              // SOIL UI
              SoilBox(soil: soil, loading: loadingSoil),

              const SizedBox(height: 25),

              // UPDATE SOIL BUTTON
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditSoilPage(uid: widget.uid, existingSoil: soil),
                    ),
                  );

                  fetchSoil(); // Refresh soil after update
                },
                child: const Text("Update Soil Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
