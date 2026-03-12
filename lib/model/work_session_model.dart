/// Tracks an active work session after employer accepts a worker.
/// Status flow: pending_arrival -> arrived_waiting_confirm -> in_progress -> completed_full | completed_today
class WorkSessionModel {
  final String id;
  final int hubId;
  final String applicationId;
  final String workerId;
  final String employerId;
  final String status; // pending_arrival, arrived_waiting_confirm, in_progress, completed_today, completed_full
  final DateTime? workerArrivedAt;
  final DateTime? employerConfirmedArrivalAt;
  final DateTime? completedAt;
  final String? completionType; // full | today
  final DateTime? scheduledWorkStart;
  final DateTime? scheduledWorkEnd;
  final double? lastWorkerLat;
  final double? lastWorkerLng;
  final DateTime? workerLeftAreaAt;
  final bool? workerStillWorking; // after leaving area

  WorkSessionModel({
    required this.id,
    required this.hubId,
    required this.applicationId,
    required this.workerId,
    required this.employerId,
    this.status = 'pending_arrival',
    this.workerArrivedAt,
    this.employerConfirmedArrivalAt,
    this.completedAt,
    this.completionType,
    this.scheduledWorkStart,
    this.scheduledWorkEnd,
    this.lastWorkerLat,
    this.lastWorkerLng,
    this.workerLeftAreaAt,
    this.workerStillWorking,
  });

  factory WorkSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkSessionModel(
      id: json['id']?.toString() ?? '',
      hubId: (json['hubId'] ?? json['hub_id'] ?? 0) as int,
      applicationId: (json['applicationId'] ?? json['application_id'] ?? '').toString(),
      workerId: (json['workerId'] ?? json['worker_id'] ?? '').toString(),
      employerId: (json['employerId'] ?? json['employer_id'] ?? '').toString(),
      status: json['status'] ?? 'pending_arrival',
      workerArrivedAt: json['workerArrivedAt'] != null ? DateTime.tryParse(json['workerArrivedAt'].toString()) : null,
      employerConfirmedArrivalAt: json['employerConfirmedArrivalAt'] != null ? DateTime.tryParse(json['employerConfirmedArrivalAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      completionType: json['completionType']?.toString(),
      scheduledWorkStart: json['scheduledWorkStart'] != null ? DateTime.tryParse(json['scheduledWorkStart'].toString()) : null,
      scheduledWorkEnd: json['scheduledWorkEnd'] != null ? DateTime.tryParse(json['scheduledWorkEnd'].toString()) : null,
      lastWorkerLat: (json['lastWorkerLat'] as num?)?.toDouble(),
      lastWorkerLng: (json['lastWorkerLng'] as num?)?.toDouble(),
      workerLeftAreaAt: json['workerLeftAreaAt'] != null ? DateTime.tryParse(json['workerLeftAreaAt'].toString()) : null,
      workerStillWorking: json['workerStillWorking'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hubId': hubId,
      'applicationId': applicationId,
      'workerId': workerId,
      'employerId': employerId,
      'status': status,
      'workerArrivedAt': workerArrivedAt?.toIso8601String(),
      'employerConfirmedArrivalAt': employerConfirmedArrivalAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completionType': completionType,
      'scheduledWorkStart': scheduledWorkStart?.toIso8601String(),
      'scheduledWorkEnd': scheduledWorkEnd?.toIso8601String(),
      'lastWorkerLat': lastWorkerLat,
      'lastWorkerLng': lastWorkerLng,
      'workerLeftAreaAt': workerLeftAreaAt?.toIso8601String(),
      'workerStillWorking': workerStillWorking,
    };
  }

  bool get isPendingArrival => status == 'pending_arrival';
  bool get isArrivedWaitingConfirm => status == 'arrived_waiting_confirm';
  bool get isInProgress => status == 'in_progress';
  bool get isCompletedToday => status == 'completed_today';
  bool get isCompletedFull => status == 'completed_full';
  bool get isActive => isPendingArrival || isArrivedWaitingConfirm || isInProgress || isCompletedToday;
}
