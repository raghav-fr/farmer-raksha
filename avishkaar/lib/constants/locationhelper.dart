import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position?> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if GPS is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    // Check permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return null; // User denied again
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Must enable manually from settings
    }

    // Permissions allowed → get location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
