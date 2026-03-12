import '../config/env_config.dart';
import '../model/payment_proof_model.dart';
import '../data/dummy_hub_data.dart';

class PaymentProofService {
  static bool get _useMock => EnvConfig.useMockData;

  static Future<void> _mockDelay() async {
    final ms = EnvConfig.mockDelay;
    if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
  }

  static Future<PaymentProofModel?> getBySession(String sessionId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getPaymentProofBySession(sessionId);
    }
    return null;
  }

  static Future<PaymentProofModel?> getByHub(int hubId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getPaymentProofByHub(hubId);
    }
    return null;
  }

  static Future<PaymentProofModel?> submitEmployerProof({
    required int hubId,
    required String sessionId,
    required double amount,
    required String proofDescription,
  }) async {
    if (_useMock) {
      await _mockDelay();
      final p = DummyHubData.submitEmployerProof(
        hubId: hubId,
        sessionId: sessionId,
        amount: amount,
        proofDescription: proofDescription,
      );
      final s = DummyHubData.getSessionById(sessionId);
      if (s != null) {
        DummyHubData.addNotificationForWorker(
          'payment_sent',
          s.workerId,
          'The employer has submitted payment proof. Please confirm receipt with your proof.',
          hubId: hubId.toString(),
        );
      }
      return p;
    }
    return null;
  }

  static Future<PaymentProofModel?> submitClientProof(String sessionId, String proofDescription) async {
    if (_useMock) {
      await _mockDelay();
      final p = DummyHubData.submitClientProof(sessionId, proofDescription);
      if (p != null && p.isComplete) {
        final s = DummyHubData.getSessionById(sessionId);
        if (s != null) {
          final hub = DummyHubData.getHubById(s.hubId);
          if (hub != null) {
            DummyHubData.addJobHistory(
              hubId: s.hubId,
              hubTitle: hub.title,
              employerId: s.employerId,
              workerId: s.workerId,
              paymentAmount: p.amount,
            );
          }
        }
      }
      return p;
    }
    return null;
  }
}
