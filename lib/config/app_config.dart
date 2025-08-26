// Simple App Configuration - No .env file needed!
class AppConfig {
  // API Configuration
  // static const String apiBaseUrl = 'http://10.50.93.130:3005';
  static const String apiBaseUrl = 'http://192.168.187.231:3005';
  static const String apiVersion = 'v1';
  static const String apiAuthEndpoint = '/user-management';
  static const String apiUsersEndpoint = '/user-management';
  static const String apiHubsEndpoint = '/jobhub';
  static const String apiApplicationsEndpoint = '/applications';
  static const int apiTimeout = 10;
  static const int apiConnectTimeout = 5;

  // App Configuration
  static const String appName = 'BusinessHub Mobile';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  static const String environment = 'development';
  static const bool debugMode = true;
  static const String logLevel = 'debug';

  // Feature Flags
  static const bool enableSocialLogin = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableErrorTracking = true;

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';

  static String get fullApiUrl => '$apiBaseUrl/$apiVersion';
  static String get authApiUrl => '$fullApiUrl$apiAuthEndpoint';
  static String get usersApiUrl => '$fullApiUrl$apiUsersEndpoint';
  static String get hubsApiUrl => '$fullApiUrl$apiHubsEndpoint';
  static String get applicationsApiUrl => '$fullApiUrl$apiApplicationsEndpoint';

  // Initialize method (for compatibility)
  static Future<void> initialize() async {
    if (debugMode) {
      print('🌍 Environment: $environment');
      print('🔗 API Base URL: $apiBaseUrl');
      print('📱 App Name: $appName');
    }
  }
}
