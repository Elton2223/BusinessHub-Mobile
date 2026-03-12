/// Completed job entry for worker history (after payment complete + ratings).
class JobHistoryModel {
  final String id;
  final int hubId;
  final String hubTitle;
  final String employerId;
  final String workerId;
  final double paymentAmount;
  final DateTime completedAt;
  final bool paymentReceived;
  final bool ratingGiven;

  JobHistoryModel({
    required this.id,
    required this.hubId,
    required this.hubTitle,
    required this.employerId,
    required this.workerId,
    required this.paymentAmount,
    required this.completedAt,
    this.paymentReceived = true,
    this.ratingGiven = false,
  });

  factory JobHistoryModel.fromJson(Map<String, dynamic> json) {
    return JobHistoryModel(
      id: json['id']?.toString() ?? '',
      hubId: (json['hubId'] ?? json['hub_id'] ?? 0) as int,
      hubTitle: (json['hubTitle'] ?? json['hub_title'] ?? '').toString(),
      employerId: (json['employerId'] ?? json['employer_id'] ?? '').toString(),
      workerId: (json['workerId'] ?? json['worker_id'] ?? '').toString(),
      paymentAmount: (json['paymentAmount'] ?? 0).toDouble(),
      completedAt: DateTime.parse(json['completedAt']?.toString() ?? DateTime.now().toIso8601String()),
      paymentReceived: json['paymentReceived'] == true,
      ratingGiven: json['ratingGiven'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hubId': hubId,
      'hubTitle': hubTitle,
      'employerId': employerId,
      'workerId': workerId,
      'paymentAmount': paymentAmount,
      'completedAt': completedAt.toIso8601String(),
      'paymentReceived': paymentReceived,
      'ratingGiven': ratingGiven,
    };
  }
}
