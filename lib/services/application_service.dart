import '../config/env_config.dart';
import '../model/hub_application_model.dart';
import '../data/dummy_hub_data.dart';
import 'hub_repository.dart';

/// Applications to hubs. Uses dummy data when [EnvConfig.useMockData]; otherwise
/// replace with API calls to backend (e.g. POST /applications, GET /applications, PATCH /applications/:id).
class ApplicationService {
  static bool get _useMock => EnvConfig.useMockData;

  static Future<List<HubApplicationModel>> getApplicationsForHub(int hubId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getApplicationsForHub(hubId);
    }
    // TODO: GET /jobhub/$hubId/applications or GET /applications?hubId=$hubId
    return [];
  }

  static Future<List<HubApplicationModel>> getMyApplications(String userId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getApplicationsByUser(userId);
    }
    // TODO: GET /applications?applicantUserId=$userId
    return [];
  }

  /// Apply to a hub. Returns null if the applicant is the hub owner (self-apply not allowed).
  static Future<HubApplicationModel?> apply({
    required int hubId,
    required String applicantUserId,
    String? message,
  }) async {
    if (_useMock) {
      await _mockDelay();
      final hub = await HubRepository.getJobhubById(hubId);
      if (hub != null && hub.registerId?.toString() == applicantUserId) return null;
      return DummyHubData.addApplication(hubId, applicantUserId, message: message);
    }
    // TODO: POST /applications { hubId, applicantUserId, message }; backend should reject self-apply
    return null;
  }

  static Future<HubApplicationModel?> getApplicationById(String id) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getApplicationById(id);
    }
    // TODO: GET /applications/$id
    return null;
  }

  static Future<void> respondToApplication(String applicationId, String status, {String? declineReason}) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.respondToApplication(applicationId, status, declineReason: declineReason);
      return;
    }
    // TODO: PATCH /applications/$id { status: 'accepted' | 'rejected', declineReason?: string }
  }

  static Future<void> _mockDelay() async {
    final ms = EnvConfig.mockDelay;
    if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
  }
}
