import 'dart:io';

class EnvConfig {
  // API Configuration
  static String get apiBaseUrl => _getEnv('API_BASE_URL', 'http://10.0.2.2:3005');
  static String get apiVersion => _getEnv('API_VERSION', 'v1');
  static String get apiAuthEndpoint => _getEnv('API_AUTH_ENDPOINT', '/user-management');
  static String get apiUsersEndpoint => _getEnv('API_USERS_ENDPOINT', '/user-management');
  static String get apiHubsEndpoint => _getEnv('API_HUBS_ENDPOINT', '/jobhub');
  static String get apiApplicationsEndpoint => _getEnv('API_APPLICATIONS_ENDPOINT', '/applications');
  static int get apiTimeout => _getEnvInt('API_TIMEOUT', 10);
  static int get apiConnectTimeout => _getEnvInt('API_CONNECT_TIMEOUT', 5);

  // App Configuration
  static String get appName => _getEnv('APP_NAME', 'BusinessHub Mobile');
  static String get appVersion => _getEnv('APP_VERSION', '1.0.0');
  static int get buildNumber => _getEnvInt('BUILD_NUMBER', 1);
  static String get environment => _getEnv('ENVIRONMENT', 'development');
  static bool get debugMode => _getEnvBool('DEBUG_MODE', true);
  static String get logLevel => _getEnv('LOG_LEVEL', 'debug');

  // Feature Flags
  static bool get enableSocialLogin => _getEnvBool('ENABLE_SOCIAL_LOGIN', true);
  static bool get enablePushNotifications => _getEnvBool('ENABLE_PUSH_NOTIFICATIONS', true);
  static bool get enableAnalytics => _getEnvBool('ENABLE_ANALYTICS', true);
  static bool get enableErrorTracking => _getEnvBool('ENABLE_ERROR_TRACKING', true);

  // Authentication & Security
  static String get jwtSecret => _getEnv('JWT_SECRET', '');
  static int get jwtExpiryHours => _getEnvInt('JWT_EXPIRY_HOURS', 24);
  static String get googleClientId => _getEnv('GOOGLE_CLIENT_ID', '');
  static String get googleClientSecret => _getEnv('GOOGLE_CLIENT_SECRET', '');
  static String get facebookAppId => _getEnv('FACEBOOK_APP_ID', '');
  static String get facebookClientToken => _getEnv('FACEBOOK_CLIENT_TOKEN', '');

  // Database Configuration
  static String get databaseUrl => _getEnv('DATABASE_URL', '');
  static String get databaseName => _getEnv('DATABASE_NAME', 'businesshub_db');

  // File Storage & Media
  static int get maxFileSize => _getEnvInt('MAX_FILE_SIZE', 10485760);
  static String get allowedFileTypes => _getEnv('ALLOWED_FILE_TYPES', 'image/jpeg,image/png,image/gif,application/pdf');
  static String get storageProvider => _getEnv('STORAGE_PROVIDER', 'aws');
  static String get storageBucket => _getEnv('STORAGE_BUCKET', 'businesshub-uploads');
  static String get storageRegion => _getEnv('STORAGE_REGION', 'us-east-1');

  // AWS S3 Configuration
  static String get awsAccessKeyId => _getEnv('AWS_ACCESS_KEY_ID', '');
  static String get awsSecretAccessKey => _getEnv('AWS_SECRET_ACCESS_KEY', '');
  static String get awsRegion => _getEnv('AWS_REGION', 'us-east-1');

  // Push Notifications
  static String get fcmServerKey => _getEnv('FCM_SERVER_KEY', '');
  static String get fcmSenderId => _getEnv('FCM_SENDER_ID', '');

  // Analytics & Monitoring
  static String get gaTrackingId => _getEnv('GA_TRACKING_ID', '');
  static String get sentryDsn => _getEnv('SENTRY_DSN', '');
  static String get sentryEnvironment => _getEnv('SENTRY_ENVIRONMENT', 'development');

  // Third-party Services
  static String get stripePublishableKey => _getEnv('STRIPE_PUBLISHABLE_KEY', '');
  static String get stripeSecretKey => _getEnv('STRIPE_SECRET_KEY', '');
  static String get smtpHost => _getEnv('SMTP_HOST', 'smtp.gmail.com');
  static int get smtpPort => _getEnvInt('SMTP_PORT', 587);
  static String get smtpUsername => _getEnv('SMTP_USERNAME', '');
  static String get smtpPassword => _getEnv('SMTP_PASSWORD', '');

  // Development & Testing
  static String get testApiBaseUrl => _getEnv('TEST_API_BASE_URL', 'https://test-api.businesshub.com');
  static String get testDatabaseUrl => _getEnv('TEST_DATABASE_URL', '');
  static bool get useMockData => _getEnvBool('USE_MOCK_DATA', false);
  static int get mockDelay => _getEnvInt('MOCK_DELAY', 1000);

  // Platform-specific Configuration
  static String get iosBundleId => _getEnv('IOS_BUNDLE_ID', 'com.businesshub.businesshubMobile');
  static String get iosTeamId => _getEnv('IOS_TEAM_ID', '');
  static String get androidPackageName => _getEnv('ANDROID_PACKAGE_NAME', 'com.businesshub.businesshub_mobile');
  static String get androidSigningKeyAlias => _getEnv('ANDROID_SIGNING_KEY_ALIAS', '');
  static String get androidSigningKeyPassword => _getEnv('ANDROID_SIGNING_KEY_PASSWORD', '');

  // Business Logic Configuration
  static int get maxHubApplicationsPerUser => _getEnvInt('MAX_HUB_APPLICATIONS_PER_USER', 5);
  static int get hubApplicationExpiryDays => _getEnvInt('HUB_APPLICATION_EXPIRY_DAYS', 30);
  static int get maxProfileImageSize => _getEnvInt('MAX_PROFILE_IMAGE_SIZE', 5242880);
  static String get allowedProfileImageTypes => _getEnv('ALLOWED_PROFILE_IMAGE_TYPES', 'image/jpeg,image/png');

  // Cache Configuration
  static int get cacheDuration => _getEnvInt('CACHE_DURATION', 3600);
  static int get maxCacheSize => _getEnvInt('MAX_CACHE_SIZE', 100);

  // Rate Limiting
  static int get rateLimitRequests => _getEnvInt('RATE_LIMIT_REQUESTS', 100);
  static int get rateLimitWindow => _getEnvInt('RATE_LIMIT_WINDOW', 3600);

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';

  static String get fullApiUrl => '$apiBaseUrl/$apiVersion';
  static String get authApiUrl => '$fullApiUrl$apiAuthEndpoint';
  static String get usersApiUrl => '$fullApiUrl$apiUsersEndpoint';
  static String get hubsApiUrl => '$fullApiUrl$apiHubsEndpoint';
  static String get applicationsApiUrl => '$fullApiUrl$apiApplicationsEndpoint';

  // Private helper methods
  static String _getEnv(String key, String defaultValue) {
    // Try to get from environment variables first
    final envValue = Platform.environment[key];
    if (envValue != null && envValue.isNotEmpty) {
      return envValue;
    }
    
    // Fallback to default
    return defaultValue;
  }

  static int _getEnvInt(String key, int defaultValue) {
    final value = _getEnv(key, '');
    return int.tryParse(value) ?? defaultValue;
  }

  static bool _getEnvBool(String key, bool defaultValue) {
    final value = _getEnv(key, '').toLowerCase();
    return value == 'true' || value == '1' || defaultValue;
  }

  // Initialize method (kept for compatibility, but simplified)
  static Future<void> initialize() async {
    // This method is now simplified since we're using Platform.environment
    // You can add any initialization logic here if needed
    if (debugMode) {
      print('🌍 Environment: $environment');
      print('🔗 API Base URL: $apiBaseUrl');
      print('📱 App Name: $appName');
    }
  }
}
