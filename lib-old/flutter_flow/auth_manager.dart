// Stub for authManager used in registration
class AuthManager {
  Future<dynamic> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Simulate a network call and return a fake user object
    await Future.delayed(Duration(seconds: 1));
    if (email == 'fail@example.com') {
      // Simulate a failure
      return null;
    }
    return {
      'uid': 'fake-uid',
      'email': email,
      'displayName': displayName,
    };
  }

  Future<dynamic> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulate a network call and return a fake user object
    await Future.delayed(Duration(seconds: 1));
    if (email == 'fail@example.com' || password == 'wrongpassword') {
      // Simulate a failure
      return null;
    }
    return {
      'uid': 'fake-uid',
      'email': email,
      'displayName': 'User Name',
    };
  }
}

final authManager = AuthManager();
