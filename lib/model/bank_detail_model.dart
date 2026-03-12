/// Bank account details for withdrawing from App Pocket.
class BankDetailModel {
  final String id;
  final String userId;
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String branchCode;
  final String? accountType; // 'savings' | 'current' | etc.

  const BankDetailModel({
    required this.id,
    required this.userId,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.branchCode,
    this.accountType,
  });
}
