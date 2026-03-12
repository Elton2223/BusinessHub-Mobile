/// Payment proof: employer submits proof, client confirms with their proof.
/// Both required for payment_done.
class PaymentProofModel {
  final String id;
  final int hubId;
  final String sessionId;
  final double amount;
  final String? employerProofDescription;
  final DateTime? employerSubmittedAt;
  final String? clientProofDescription;
  final DateTime? clientConfirmedAt;

  PaymentProofModel({
    required this.id,
    required this.hubId,
    required this.sessionId,
    required this.amount,
    this.employerProofDescription,
    this.employerSubmittedAt,
    this.clientProofDescription,
    this.clientConfirmedAt,
  });

  bool get employerSubmitted => employerSubmittedAt != null;
  bool get clientConfirmed => clientConfirmedAt != null;
  bool get isComplete => employerSubmitted && clientConfirmed;

  factory PaymentProofModel.fromJson(Map<String, dynamic> json) {
    return PaymentProofModel(
      id: json['id']?.toString() ?? '',
      hubId: (json['hubId'] ?? json['hub_id'] ?? 0) as int,
      sessionId: (json['sessionId'] ?? json['session_id'] ?? '').toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      employerProofDescription: json['employerProofDescription']?.toString(),
      employerSubmittedAt: json['employerSubmittedAt'] != null ? DateTime.tryParse(json['employerSubmittedAt'].toString()) : null,
      clientProofDescription: json['clientProofDescription']?.toString(),
      clientConfirmedAt: json['clientConfirmedAt'] != null ? DateTime.tryParse(json['clientConfirmedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hubId': hubId,
      'sessionId': sessionId,
      'amount': amount,
      'employerProofDescription': employerProofDescription,
      'employerSubmittedAt': employerSubmittedAt?.toIso8601String(),
      'clientProofDescription': clientProofDescription,
      'clientConfirmedAt': clientConfirmedAt?.toIso8601String(),
    };
  }
}
