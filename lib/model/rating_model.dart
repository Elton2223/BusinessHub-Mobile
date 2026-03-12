/// Rating given by one user to another for a hub (as worker or as employer).
/// Backend API: POST/GET /ratings (or /jobhub/:id/ratings)
class RatingModel {
  final String? id;
  final int hubId;
  final String fromUserId;
  final String toUserId;
  final int rating; // 1-5
  final String? comment;
  final String role; // as_worker | as_employer
  final DateTime createdAt;

  RatingModel({
    this.id,
    required this.hubId,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    this.comment,
    required this.role,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id']?.toString(),
      hubId: (json['hubId'] ?? json['hub_id'] ?? 0) as int,
      fromUserId: (json['fromUserId'] ?? json['from_user_id'] ?? '').toString(),
      toUserId: (json['toUserId'] ?? json['to_user_id'] ?? '').toString(),
      rating: (json['rating'] ?? 0) as int,
      comment: json['comment'],
      role: json['role'] ?? 'as_worker',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hubId': hubId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'rating': rating,
      'comment': comment,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
