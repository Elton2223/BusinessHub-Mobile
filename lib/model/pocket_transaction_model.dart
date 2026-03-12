/// A single transaction in the user's App Pocket (earning, deposit, withdrawal).
class PocketTransactionModel {
  final String id;
  final String userId;
  final String type; // 'earning' | 'deposit' | 'withdrawal'
  final double amount;
  final String? description;
  final String? referenceId; // hubId or sessionId for earnings
  final DateTime createdAt;
  final String status; // 'completed' | 'pending' | 'failed'

  const PocketTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    required this.createdAt,
    this.status = 'completed',
  });

  bool get isCredit => type == 'earning' || type == 'deposit';
  bool get isDebit => type == 'withdrawal';
}
