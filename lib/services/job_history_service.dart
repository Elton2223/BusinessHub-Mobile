import '../config/env_config.dart';
import '../model/job_history_model.dart';
import '../data/dummy_hub_data.dart';

class JobHistoryService {
  static bool get _useMock => EnvConfig.useMockData;

  static Future<void> _mockDelay() async {
    final ms = EnvConfig.mockDelay;
    if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
  }

  static Future<List<JobHistoryModel>> getHistoryForWorker(String workerId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getJobHistoryForWorker(workerId);
    }
    return [];
  }

  /// Job history for user (as worker and/or employer). roleFilter: 'all' | 'worker' | 'employer'. Paginated.
  static Future<Map<String, dynamic>> getHistoryForUserPaginated(
    String userId, {
    String roleFilter = 'all',
    int page = 0,
    int pageSize = 10,
  }) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getJobHistoryForUserPaginated(
        userId,
        roleFilter: roleFilter,
        page: page,
        pageSize: pageSize,
      );
    }
    return {'list': <JobHistoryModel>[], 'total': 0};
  }

  static Future<void> markRatingGiven(String historyId) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.markHistoryRatingGiven(historyId);
    }
  }
}
