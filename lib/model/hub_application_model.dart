/// Model for a user's application to a hub/job.
/// Backend API: POST/GET /applications (or /jobhub/:id/applications)
class HubApplicationModel {
  final String? id;
  final int hubId;
  final String applicantUserId;
  final String status; // pending, accepted, rejected
  final String? message;
  final String? declineReason; // required when status is rejected; shown to applicant to rectify profile
  final DateTime createdAt;
  final DateTime? respondedAt;

  HubApplicationModel({
    this.id,
    required this.hubId,
    required this.applicantUserId,
    this.status = 'pending',
    this.message,
    this.declineReason,
    required this.createdAt,
    this.respondedAt,
  });

  factory HubApplicationModel.fromJson(Map<String, dynamic> json) {
    return HubApplicationModel(
      id: json['id']?.toString(),
      hubId: (json['hubId'] ?? json['hub_id'] ?? 0) as int,
      applicantUserId: (json['applicantUserId'] ?? json['applicant_user_id'] ?? '').toString(),
      status: json['status'] ?? 'pending',
      message: json['message'],
      declineReason: json['declineReason']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now()),
      respondedAt: json['respondedAt'] != null
          ? DateTime.tryParse(json['respondedAt'].toString())
          : (json['responded_at'] != null ? DateTime.tryParse(json['responded_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hubId': hubId,
      'applicantUserId': applicantUserId,
      'status': status,
      'message': message,
      'declineReason': declineReason,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}
