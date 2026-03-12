/// In-app notification (e.g. new application, accepted, rejected).
/// Backend API: GET /notifications, PATCH /notifications/:id/read
class NotificationModel {
  final String id;
  final String type; // application_received, application_accepted, application_rejected, hub_completed
  final String title;
  final String body;
  final String? relatedHubId;
  final String? relatedApplicationId;
  final String? fromUserId;
  final String toUserId;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.relatedHubId,
    this.relatedApplicationId,
    this.fromUserId,
    required this.toUserId,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      relatedHubId: json['relatedHubId']?.toString(),
      relatedApplicationId: json['relatedApplicationId']?.toString(),
      fromUserId: json['fromUserId']?.toString(),
      toUserId: (json['toUserId'] ?? json['to_user_id'] ?? '').toString(),
      read: json['read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'relatedHubId': relatedHubId,
      'relatedApplicationId': relatedApplicationId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
