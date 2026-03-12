import '../config/env_config.dart';
import '../model/notification_model.dart';
import '../data/dummy_hub_data.dart';

/// Notifications. Uses dummy data when [EnvConfig.useMockData]; otherwise
/// replace with API: GET /notifications, PATCH /notifications/:id/read.
class NotificationService {
  static bool get _useMock => EnvConfig.useMockData;

  static Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getNotificationsForUser(userId);
    }
    // TODO: GET /notifications?toUserId=$userId
    return [];
  }

  static Future<int> getUnreadCount(String userId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getUnreadCount(userId);
    }
    // TODO: GET /notifications/count?toUserId=$userId&read=false
    return 0;
  }

  static Future<void> markAsRead(String notificationId) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.markNotificationRead(notificationId);
      return;
    }
    // TODO: PATCH /notifications/$id { read: true }
  }

  /// When employer accepts an application, remove the "application_received" notification so it no longer appears or counts.
  static Future<void> removeApplicationReceivedForApplication(String applicationId, String toUserId) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.removeApplicationReceivedForApplication(applicationId, toUserId);
      return;
    }
    // TODO: DELETE or PATCH notifications for this application (backend)
  }

  /// Called after an application is submitted; notifies the hub owner.
  static Future<void> notifyApplicationReceived({
    required String toUserId,
    required String fromUserId,
    required int hubId,
    required String applicationId,
    required String hubTitle,
    required String applicantName,
  }) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.createApplicationReceivedNotification(
        toUserId: toUserId,
        fromUserId: fromUserId,
        hubId: hubId,
        applicationId: applicationId,
        hubTitle: hubTitle,
        applicantName: applicantName,
      );
      return;
    }
    // TODO: POST /notifications (backend creates this when application is submitted)
  }

  /// Called when hub owner accepts/rejects; notifies the applicant. For rejections, [declineReason] is shown so the client can rectify their profile.
  static Future<void> notifyApplicationResponded({
    required String toUserId,
    required String type,
    required String hubTitle,
    required String applicationId,
    String? declineReason,
  }) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.createApplicationRespondedNotification(
        toUserId: toUserId,
        type: type,
        hubTitle: hubTitle,
        applicationId: applicationId,
        declineReason: declineReason,
      );
      return;
    }
    // TODO: POST /notifications
  }

  static Future<void> _mockDelay() async {
    final ms = EnvConfig.mockDelay;
    if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
  }
}
