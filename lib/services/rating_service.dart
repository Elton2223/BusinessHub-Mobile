import '../config/env_config.dart';
import '../model/rating_model.dart';
import '../data/dummy_hub_data.dart';

/// Ratings (worker/employer). Uses dummy data when [EnvConfig.useMockData];
/// replace with API: POST /ratings, GET /ratings?toUserId=.
class RatingService {
  static bool get _useMock => EnvConfig.useMockData;

  static Future<List<RatingModel>> getRatingsForUser(String userId) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.getRatingsForUser(userId);
    }
    // TODO: GET /ratings?toUserId=$userId
    return [];
  }

  static Future<RatingModel?> submitRating({
    required int hubId,
    required String fromUserId,
    required String toUserId,
    required int rating,
    String? comment,
    required String role,
  }) async {
    if (_useMock) {
      await _mockDelay();
      return DummyHubData.addRating(RatingModel(
        hubId: hubId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        rating: rating,
        comment: comment,
        role: role,
        createdAt: DateTime.now(),
      ));
    }
    // TODO: POST /ratings { hubId, fromUserId, toUserId, rating, comment, role }
    return null;
  }

  static Future<void> _mockDelay() async {
    final ms = EnvConfig.mockDelay;
    if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
  }
}
