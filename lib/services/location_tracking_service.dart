import 'dart:math';
import 'package:geolocator/geolocator.dart';

/// 50m radius for job location tracking (worker must be within this to be "at work").
const double kWorkLocationRadiusMeters = 50.0;

class LocationTrackingService {
  static const double workRadiusMeters = kWorkLocationRadiusMeters;
  /// Distance in meters between two lat/lng points (Haversine).
  static double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a)); // 12742 km -> meters
  }

  /// Returns true if (userLat, userLng) is within [radiusMeters] of (hubLat, hubLng).
  static bool isWithinRadius({
    required double userLat,
    required double userLng,
    required double hubLat,
    required double hubLng,
    double radiusMeters = kWorkLocationRadiusMeters,
  }) {
    return distanceMeters(userLat, userLng, hubLat, hubLng) <= radiusMeters;
  }

  /// Get current device position. Request permission if needed.
  static Future<Position?> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if current location is within work radius of hub. Returns distance in meters (or null if location unavailable).
  static Future<double?> getDistanceToHub({
    required double hubLat,
    required double hubLng,
  }) async {
    final pos = await getCurrentPosition();
    if (pos == null) return null;
    return distanceMeters(pos.latitude, pos.longitude, hubLat, hubLng);
  }
}
