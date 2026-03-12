import '../config/env_config.dart';
import '../model/pocket_transaction_model.dart';
import '../model/bank_detail_model.dart';
import '../data/dummy_hub_data.dart';

class PocketService {
  static bool get _useMock => EnvConfig.useMockData;

  static Future<void> _mockDelay() async {
    final ms = EnvConfig.mockDelay;
    if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
  }

  static Future<double> getBalance(String userId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getPocketBalance(userId);
    }
    // TODO: GET /pocket/balance
    return 0.0;
  }

  static Future<List<PocketTransactionModel>> getTransactions(String userId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getPocketTransactions(userId);
    }
    // TODO: GET /pocket/transactions
    return [];
  }

  /// Add earning when work is completed (full). Called from WorkSessionService.
  static Future<void> addEarning(String userId, double amount, int hubId, [String? description]) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.addPocketEarning(userId, amount, hubId, description);
    }
    // TODO: POST /pocket/earning
  }

  static Future<void> addDeposit(String userId, double amount, [String? description]) async {
    if (_useMock) {
      await _mockDelay();
      DummyHubData.addPocketDeposit(userId, amount, description);
    }
    // TODO: POST /pocket/deposit
  }

  static Future<List<BankDetailModel>> getBankDetails(String userId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getBankDetails(userId);
    }
    // TODO: GET /pocket/bank-details
    return [];
  }

  static Future<BankDetailModel?> saveBankDetail({
    required String userId,
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String branchCode,
    String? accountType,
  }) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.addBankDetail(
        userId: userId,
        accountHolderName: accountHolderName,
        bankName: bankName,
        accountNumber: accountNumber,
        branchCode: branchCode,
        accountType: accountType,
      );
    }
    // TODO: POST /pocket/bank-details
    return null;
  }

  static Future<bool> withdrawToBank(String userId, double amount, String bankDetailId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.withdrawToBank(userId, amount, bankDetailId);
    }
    // TODO: POST /pocket/withdraw
    return false;
  }
}
