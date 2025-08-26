import 'dart:io';

class EnvConfig {
  static const String _envFile = '.env';
  static Map<String, String> _envVars = {};

  // Initialize environment variables
  static Future<void> initialize() async {
    try {
      final file = File(_envFile);
      if (await file.exists()) {
        final lines = await file.readAsLines();
        for (final line in lines) {
          if (line.trim().isNotEmpty && !line.startsWith('#')) {
            final parts = line.split('=');
            if (parts.length >= 2) {
              final key = parts[0].trim();
              final value = parts.sublist(1).join('=').trim();
              _envVars[key] = value;
            }
          }
        }
      }
    } catch (e) {
      print('Error loading environment file: $e');
    }
  }

  // Get environment variable
  static String get(String key, {String defaultValue = ''}) {
    return _envVars[key] ?? defaultValue;
  }

  // Get environment variable as int
  static int getInt(String key, {int defaultValue = 0}) {
    final value = get(key);
    return int.tryParse(value) ?? defaultValue;
  }

  // Get environment variable as bool
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = get(key).toLowerCase();
    return value == 'true' || value == '1' || defaultValue;
  }

  // Get environment variable as double
  static double getDouble(String key, {double defaultValue = 0.0}) {
    final value = get(key);
    return double.tryParse(value) ?? defaultValue;
  }

  // Check if environment variable exists
  static bool has(String key) {
    return _envVars.containsKey(key);
  }

  // Get all environment variables
  static Map<String, String> getAll() {
    return Map.unmodifiable(_envVars);
  }

  // API Configuration
  static String get apiBaseUrl => get('API_BASE_URL', defaultValue: 'http://192.168.187.231:3005');
  static String get apiVersion => get('API_VERSION', defaultValue: 'v1');
  static String get apiAuthEndpoint => get('API_AUTH_ENDPOINT', defaultValue: '/auth');
  static String get apiUsersEndpoint => get('API_USERS_ENDPOINT', defaultValue: '/users');
  static String get apiHubsEndpoint => get('API_HUBS_ENDPOINT', defaultValue: '/hubs');
  static String get apiApplicationsEndpoint => get('API_APPLICATIONS_ENDPOINT', defaultValue: '/applications');
  static int get apiTimeout => getInt('API_TIMEOUT', defaultValue: 30);
  static int get apiConnectTimeout => getInt('API_CONNECT_TIMEOUT', defaultValue: 10);

  // Authentication & Security
  static String get jwtSecret => get('JWT_SECRET');
  static int get jwtExpiryHours => getInt('JWT_EXPIRY_HOURS', defaultValue: 24);
  static String get googleClientId => get('GOOGLE_CLIENT_ID');
  static String get googleClientSecret => get('GOOGLE_CLIENT_SECRET');
  static String get facebookAppId => get('FACEBOOK_APP_ID');
  static String get facebookClientToken => get('FACEBOOK_CLIENT_TOKEN');

  // Database Configuration
  static String get databaseUrl => get('DATABASE_URL');
  static String get databaseName => get('DATABASE_NAME', defaultValue: 'businesshub_db');

  // File Storage & Media
  static int get maxFileSize => getInt('MAX_FILE_SIZE', defaultValue: 10485760);
  static String get allowedFileTypes => get('ALLOWED_FILE_TYPES', defaultValue: 'image/jpeg,image/png,image/gif,application/pdf');
  static String get storageProvider => get('STORAGE_PROVIDER', defaultValue: 'aws');
  static String get storageBucket => get('STORAGE_BUCKET', defaultValue: 'businesshub-uploads');
  static String get storageRegion => get('STORAGE_REGION', defaultValue: 'us-east-1');

  // AWS S3 Configuration
  static String get awsAccessKeyId => get('AWS_ACCESS_KEY_ID');
  static String get awsSecretAccessKey => get('AWS_SECRET_ACCESS_KEY');
  static String get awsRegion => get('AWS_REGION', defaultValue: 'us-east-1');

  // Push Notifications
  static String get fcmServerKey => get('FCM_SERVER_KEY');
  static String get fcmSenderId => get('FCM_SENDER_ID');

  // Analytics & Monitoring
  static String get gaTrackingId => get('GA_TRACKING_ID');
  static String get sentryDsn => get('SENTRY_DSN');
  static String get sentryEnvironment => get('SENTRY_ENVIRONMENT', defaultValue: 'development');

  // Feature Flags
  static bool get enableSocialLogin => getBool('ENABLE_SOCIAL_LOGIN', defaultValue: true);
  static bool get enablePushNotifications => getBool('ENABLE_PUSH_NOTIFICATIONS', defaultValue: true);
  static bool get enableAnalytics => getBool('ENABLE_ANALYTICS', defaultValue: true);
  static bool get enableErrorTracking => getBool('ENABLE_ERROR_TRACKING', defaultValue: true);

  // App Configuration
  static String get appName => get('APP_NAME', defaultValue: 'BusinessHub Mobile');
  static String get appVersion => get('APP_VERSION', defaultValue: '1.0.0');
  static int get buildNumber => getInt('BUILD_NUMBER', defaultValue: 1);
  static String get environment => get('ENVIRONMENT', defaultValue: 'development');
  static bool get debugMode => getBool('DEBUG_MODE', defaultValue: true);
  static String get logLevel => get('LOG_LEVEL', defaultValue: 'debug');

  // Third-party Services
  static String get stripePublishableKey => get('STRIPE_PUBLISHABLE_KEY');
  static String get stripeSecretKey => get('STRIPE_SECRET_KEY');
  static String get smtpHost => get('SMTP_HOST', defaultValue: 'smtp.gmail.com');
  static int get smtpPort => getInt('SMTP_PORT', defaultValue: 587);
  static String get smtpUsername => get('SMTP_USERNAME');
  static String get smtpPassword => get('SMTP_PASSWORD');

  // Development & Testing
  static String get testApiBaseUrl => get('TEST_API_BASE_URL', defaultValue: 'https://test-api.businesshub.com');
  static String get testDatabaseUrl => get('TEST_DATABASE_URL');
  static bool get useMockData => getBool('USE_MOCK_DATA', defaultValue: false);
  static int get mockDelay => getInt('MOCK_DELAY', defaultValue: 1000);

  // Platform-specific Configuration
  static String get iosBundleId => get('IOS_BUNDLE_ID', defaultValue: 'com.businesshub.businesshubMobile');
  static String get iosTeamId => get('IOS_TEAM_ID');
  static String get androidPackageName => get('ANDROID_PACKAGE_NAME', defaultValue: 'com.businesshub.businesshub_mobile');
  static String get androidSigningKeyAlias => get('ANDROID_SIGNING_KEY_ALIAS');
  static String get androidSigningKeyPassword => get('ANDROID_SIGNING_KEY_PASSWORD');

  // Business Logic Configuration
  static int get maxHubApplicationsPerUser => getInt('MAX_HUB_APPLICATIONS_PER_USER', defaultValue: 5);
  static int get hubApplicationExpiryDays => getInt('HUB_APPLICATION_EXPIRY_DAYS', defaultValue: 30);
  static int get maxProfileImageSize => getInt('MAX_PROFILE_IMAGE_SIZE', defaultValue: 5242880);
  static String get allowedProfileImageTypes => get('ALLOWED_PROFILE_IMAGE_TYPES', defaultValue: 'image/jpeg,image/png');

  // Cache Configuration
  static int get cacheDuration => getInt('CACHE_DURATION', defaultValue: 3600);
  static int get maxCacheSize => getInt('MAX_CACHE_SIZE', defaultValue: 100);

  // Rate Limiting
  static int get rateLimitRequests => getInt('RATE_LIMIT_REQUESTS', defaultValue: 100);
  static int get rateLimitWindow => getInt('RATE_LIMIT_WINDOW', defaultValue: 3600);

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';

  static String get fullApiUrl => '$apiBaseUrl/$apiVersion';
  static String get authApiUrl => '$fullApiUrl$apiAuthEndpoint';
  static String get usersApiUrl => '$fullApiUrl$apiUsersEndpoint';
  static String get hubsApiUrl => '$fullApiUrl$apiHubsEndpoint';
  static String get applicationsApiUrl => '$fullApiUrl$apiApplicationsEndpoint';
}
