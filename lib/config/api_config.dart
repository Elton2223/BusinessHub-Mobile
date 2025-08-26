class ApiConfig {
  // Base URL for the LoopBack4 API
  static const String baseUrl = 'http://192.168.187.231:3005';
  
  // API Endpoints
  static const String userManagementEndpoint = '/user-management';
  
  // Timeout settings
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Get full URL for an endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  // Get user management URL
  static String get userManagementUrl => getUrl(userManagementEndpoint);
  
}
