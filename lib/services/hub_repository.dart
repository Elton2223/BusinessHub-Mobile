import 'dart:math';
import '../config/env_config.dart';
import '../model/jobhub_model.dart';
import '../data/dummy_hub_data.dart';
import 'jobhub_service.dart';

/// Single entry point for hub/job data. Uses dummy data when [EnvConfig.useMockData]
/// is true; otherwise calls the real API. Replace API calls in [JobhubService] and
/// backend to match these method signatures.
class HubRepository {
  static bool get _useMock => EnvConfig.useMockData;

  static Future<List<JobhubModel>> getAllJobhubs() async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getHubs();
    }
    return JobhubService.getAllJobhubs();
  }

  static Future<JobhubModel?> getJobhubById(int id) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getHubById(id);
    }
    try {
      return await JobhubService.getJobhubById(id);
    } catch (_) {
      return null;
    }
  }

  static Future<List<JobhubModel>> getAvailableJobhubs() async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getAvailableHubs();
    }
    return JobhubService.getAvailableJobhubs();
  }

  /// Available hubs sorted by distance (closest first). Pass null coords to skip sorting.
  static Future<List<JobhubModel>> getAvailableJobhubsSortedByDistance(double? userLat, double? userLng) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getAvailableHubsSortedByDistance(userLat, userLng);
    }
    final list = await JobhubService.getAvailableJobhubs();
    return sortByDistance(list, userLat, userLng);
  }

  /// Distance in km from (userLat, userLng) to hub location.
  static double distanceKm(double userLat, double userLng, JobhubModel hub) {
    final lat = double.tryParse(hub.latitude) ?? 0.0;
    final lng = double.tryParse(hub.longitude) ?? 0.0;
    return _haversineKm(userLat, userLng, lat, lng);
  }

  /// Sort hubs by distance (closest first). Returns new list; null coords = no sort.
  static List<JobhubModel> sortByDistance(List<JobhubModel> hubs, double? userLat, double? userLng) {
    if (userLat == null || userLng == null) return hubs;
    final out = List<JobhubModel>.from(hubs);
    out.sort((a, b) {
      final dA = distanceKm(userLat, userLng, a);
      final dB = distanceKm(userLat, userLng, b);
      return dA.compareTo(dB);
    });
    return out;
  }

  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  static Future<List<JobhubModel>> getActiveJobhubs() async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getActiveHubs();
    }
    return JobhubService.getActiveJobhubs();
  }

  /// Hub IDs that have a completed work session (exclude from active/ongoing).
  static Future<Set<int>> getHubIdsWithCompletedSession() async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getHubIdsWithCompletedSession();
    }
    return {};
  }

  static Future<List<JobhubModel>> getJobhubsByCategory(String category) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getHubsByCategory(category);
    }
    return JobhubService.getJobhubsByCategory(category);
  }

  /// Hubs created by the given user (my hubs as employer).
  static Future<List<JobhubModel>> getMyHubs(String userId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getHubsByOwner(userId);
    }
    // TODO: GET /jobhub?registerId= or /jobhub?ownerId=
    return JobhubService.getAllJobhubs().then((list) =>
        list.where((h) => h.registerId?.toString() == userId).toList());
  }

  static Future<List<JobhubModel>> getJobhubsNear(
    double? userLat,
    double? userLng,
    double radiusKm,
  ) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getHubsNear(userLat, userLng, radiusKm);
    }
    // Backend: e.g. GET /jobhub?lat=&lng=&radiusKm=
    return JobhubService.getAllJobhubs();
  }

  static Future<JobhubModel> createJobhub(JobhubModel jobhub) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.addHub(jobhub);
    }
    return JobhubService.createJobhub(jobhub);
  }

  static Future<void> updateJobhub(int id, JobhubModel jobhub) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.updateHub(id, jobhub);
      return;
    }
    await JobhubService.updateJobhub(id, jobhub);
  }

  static Future<void> deleteJobhub(int id) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.deleteHub(id);
      return;
    }
    await JobhubService.deleteJobhub(id);
  }

  static Future<void> _mockDelay() async {
    final ms = EnvConfig.mockDelay;
    if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
  }
}
