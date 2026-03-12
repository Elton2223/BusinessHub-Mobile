import '../config/env_config.dart';
import '../model/work_session_model.dart';
import '../data/dummy_hub_data.dart';
import 'pocket_service.dart';

class WorkSessionService {
  static bool get _useMock => EnvConfig.useMockData;

  static Future<void> _mockDelay() async {
    final ms = EnvConfig.mockDelay;
    if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// Call when employer accepts an application: create a work session.
  static Future<WorkSessionModel?> createSessionWhenAccepted({
    required int hubId,
    required String applicationId,
    required String workerId,
    required String employerId,
  }) async {
    if (_useMock) {
      await _mockDelay();
      final session = DummyHubData.createSession(
        hubId: hubId,
        applicationId: applicationId,
        workerId: workerId,
        employerId: employerId,
      );
      return session;
    }
    // TODO: POST /work-sessions
    return null;
  }

  static Future<WorkSessionModel?> getSessionByHubAndApplication(int hubId, String applicationId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getSessionByHubAndApplication(hubId, applicationId);
    }
    return null;
  }

  static Future<WorkSessionModel?> getSessionById(String sessionId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getSessionById(sessionId);
    }
    return null;
  }

  static Future<List<WorkSessionModel>> getActiveSessionsForWorker(String workerId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getSessionsForWorker(workerId);
    }
    return [];
  }

  static Future<List<WorkSessionModel>> getActiveSessionsForEmployer(String employerId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getSessionsForEmployer(employerId);
    }
    return [];
  }

  /// Worker arrived within 50m – notify employer.
  static Future<void> reportWorkerArrived(String sessionId, double lat, double lng) async {
    if (_useMock) {
      await _mockDelay();
      final s = DummyHubData.getSessionById(sessionId);
      if (s == null || !s.isPendingArrival) return;
      DummyHubData.setWorkerArrived(sessionId, lat, lng);
      final workerName = DummyHubData.getDummyUser(s.workerId);
      final name = workerName != null ? '${workerName['name']} ${workerName['surname']}' : 'The worker';
      DummyHubData.addNotificationForEmployer(
        'worker_arrived',
        s.employerId,
        '$name has arrived at the job location (within 50m). Confirm their arrival.',
        hubId: s.hubId.toString(),
      );
    }
  }

  static Future<void> confirmWorkerArrival(String sessionId) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.confirmWorkerArrival(sessionId);
    }
  }

  /// Worker left the 50m radius while in progress – notify employer (once per leave).
  static Future<void> reportWorkerLeftArea(String sessionId) async {
    if (_useMock) {
      await _mockDelay();
      final s = DummyHubData.getSessionById(sessionId);
      if (s == null || !s.isInProgress) return;
      if (s.workerLeftAreaAt != null) return; // Already notified for this leave
      DummyHubData.setWorkerLeftArea(sessionId);
      DummyHubData.addNotificationForEmployer(
        'worker_left_area',
        s.employerId,
        'The worker has left the job area (50m). Are they still working or finished for now?',
        hubId: s.hubId.toString(),
      );
    }
  }

  /// Employer completes work: full (job done) or today (continues another day).
  static Future<void> completeWork(String sessionId, String completionType) async {
    if (_useMock) {
      await _mockDelay();
      final s = DummyHubData.getSessionById(sessionId);
      if (s == null) return;
      DummyHubData.completeSession(sessionId, completionType);
      if (completionType == 'full') {
        final hub = DummyHubData.getHubById(s.hubId);
        final amount = hub?.paymentAmount ?? 0.0;
        final amountStr = 'R${amount.toStringAsFixed(2)}';
        DummyHubData.addNotificationForWorker(
          'session_completed',
          s.workerId,
          'Your work for this job has been marked as completed. The agreed amount $amountStr will reflect in your App Pocket. The employer will send payment.',
          hubId: s.hubId.toString(),
        );
        await PocketService.addEarning(s.workerId, amount, s.hubId, 'Job completed');
      }
    }
  }

  /// Get session for hub (e.g. for employer view). Tries employer id first, then fallback by hubId so owner always gets session.
  static Future<WorkSessionModel?> getSessionForHub(int hubId, String employerId) async {
    if (_useMock) {
      await _mockDelay();
      final byEmployer = DummyHubData.getSessionsForEmployer(employerId);
      try {
        return byEmployer.firstWhere((s) => s.hubId == hubId);
      } catch (_) {
        final byHub = DummyHubData.getSessionByHubId(hubId);
        if (byHub != null && byHub.employerId == employerId) return byHub;
        return null;
      }
    }
    return null;
  }
}
