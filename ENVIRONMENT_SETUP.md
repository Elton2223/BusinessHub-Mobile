# Environment Configuration Setup

This guide explains how to set up and use environment variables in the BusinessHub Mobile Flutter project.

## 📁 Files Overview

- `env.example` - Template file with all available environment variables
- `lib/config/env_config.dart` - Flutter configuration class to access environment variables
- `.env` - Your actual environment file (create this from env.example)

## 🚀 Quick Setup

1. **Copy the template file:**
   ```bash
   cp env.example .env
   ```

2. **Edit the .env file:**
   Open `.env` and replace the placeholder values with your actual configuration.

3. **Initialize in your app:**
   In your `main.dart`, add this before `runApp()`:
   ```dart
   import 'config/env_config.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await EnvConfig.initialize();
     runApp(const MyApp());
   }
   ```

## 🔧 Using Environment Variables

### Basic Usage

```dart
import 'config/env_config.dart';

// Get string values
String apiUrl = EnvConfig.apiBaseUrl;
String appName = EnvConfig.appName;

// Get numeric values
int timeout = EnvConfig.apiTimeout;
int maxFileSize = EnvConfig.maxFileSize;

// Get boolean values
bool isDebug = EnvConfig.debugMode;
bool enableAnalytics = EnvConfig.enableAnalytics;

// Get environment-specific values
if (EnvConfig.isDevelopment) {
  // Development-specific code
}
```

### API Configuration

```dart
// Use pre-built API URLs
String authUrl = EnvConfig.authApiUrl;
String usersUrl = EnvConfig.usersApiUrl;
String hubsUrl = EnvConfig.hubsApiUrl;

// Or build custom URLs
String customEndpoint = '${EnvConfig.fullApiUrl}/custom-endpoint';
```

### Feature Flags

```dart
// Check if features are enabled
if (EnvConfig.enableSocialLogin) {
  // Show social login buttons
}

if (EnvConfig.enablePushNotifications) {
  // Initialize push notifications
}
```

## 📋 Environment Variables Categories

### 🔗 API Configuration
- `API_BASE_URL` - Base URL for your backend API
- `API_VERSION` - API version (e.g., v1, v2)
- `API_TIMEOUT` - Request timeout in seconds
- `API_CONNECT_TIMEOUT` - Connection timeout in seconds

### 🔐 Authentication & Security
- `JWT_SECRET` - Secret key for JWT tokens
- `JWT_EXPIRY_HOURS` - Token expiration time
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `FACEBOOK_APP_ID` - Facebook OAuth app ID

### 💾 Database Configuration
- `DATABASE_URL` - Database connection string
- `DATABASE_NAME` - Database name

### 📁 File Storage & Media
- `MAX_FILE_SIZE` - Maximum file upload size in bytes
- `ALLOWED_FILE_TYPES` - Comma-separated list of allowed file types
- `STORAGE_PROVIDER` - Cloud storage provider (aws, gcp, azure)
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

### 🔔 Push Notifications
- `FCM_SERVER_KEY` - Firebase Cloud Messaging server key
- `FCM_SENDER_ID` - FCM sender ID

### 📊 Analytics & Monitoring
- `GA_TRACKING_ID` - Google Analytics tracking ID
- `SENTRY_DSN` - Sentry error tracking DSN
- `SENTRY_ENVIRONMENT` - Environment name for Sentry

### 🚩 Feature Flags
- `ENABLE_SOCIAL_LOGIN` - Enable/disable social login
- `ENABLE_PUSH_NOTIFICATIONS` - Enable/disable push notifications
- `ENABLE_ANALYTICS` - Enable/disable analytics
- `ENABLE_ERROR_TRACKING` - Enable/disable error tracking

### ⚙️ App Configuration
- `APP_NAME` - Application name
- `APP_VERSION` - Application version
- `ENVIRONMENT` - Environment (development, staging, production)
- `DEBUG_MODE` - Enable/disable debug mode
- `LOG_LEVEL` - Logging level (debug, info, warning, error)

### 💳 Third-party Services
- `STRIPE_PUBLISHABLE_KEY` - Stripe publishable key
- `STRIPE_SECRET_KEY` - Stripe secret key
- `SMTP_HOST` - SMTP server host
- `SMTP_PORT` - SMTP server port
- `SMTP_USERNAME` - SMTP username
- `SMTP_PASSWORD` - SMTP password

### 🧪 Development & Testing
- `TEST_API_BASE_URL` - Test API base URL
- `TEST_DATABASE_URL` - Test database URL
- `USE_MOCK_DATA` - Use mock data for testing
- `MOCK_DELAY` - Mock API delay in milliseconds

### 📱 Platform-specific Configuration
- `IOS_BUNDLE_ID` - iOS bundle identifier
- `IOS_TEAM_ID` - iOS team ID
- `ANDROID_PACKAGE_NAME` - Android package name
- `ANDROID_SIGNING_KEY_ALIAS` - Android signing key alias
- `ANDROID_SIGNING_KEY_PASSWORD` - Android signing key password

### 🏢 Business Logic Configuration
- `MAX_HUB_APPLICATIONS_PER_USER` - Maximum hub applications per user
- `HUB_APPLICATION_EXPIRY_DAYS` - Hub application expiry period
- `MAX_PROFILE_IMAGE_SIZE` - Maximum profile image size
- `ALLOWED_PROFILE_IMAGE_TYPES` - Allowed profile image types

### 💾 Cache Configuration
- `CACHE_DURATION` - Cache duration in seconds
- `MAX_CACHE_SIZE` - Maximum cache size in MB

### ⚡ Rate Limiting
- `RATE_LIMIT_REQUESTS` - Maximum requests per window
- `RATE_LIMIT_WINDOW` - Rate limit window in seconds

## 🔒 Security Best Practices

1. **Never commit .env files:**
   ```bash
   # Add to .gitignore
   .env
   .env.local
   .env.production
   ```

2. **Use different values for different environments:**
   - Development: Use local/test values
   - Staging: Use staging server values
   - Production: Use production server values

3. **Rotate secrets regularly:**
   - API keys
   - JWT secrets
   - Database passwords

4. **Use strong, unique values:**
   - Generate random strings for secrets
   - Use different values for each environment

## 🌍 Environment-specific Files

You can create environment-specific files:

```bash
.env.development
.env.staging
.env.production
```

Then load the appropriate file based on your build configuration:

```dart
// In your build configuration
const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
final envFile = '.env.$environment';
```

## 🔍 Debugging

To debug environment variable loading:

```dart
// Print all environment variables
print('All env vars: ${EnvConfig.getAll()}');

// Check if a specific variable exists
if (EnvConfig.has('API_BASE_URL')) {
  print('API_BASE_URL is set');
}

// Get with default value
String apiUrl = EnvConfig.get('API_BASE_URL', defaultValue: 'http://localhost:3000');
```

## 📝 Example Usage in Your App

### API Service
```dart
class ApiService {
  static final String baseUrl = EnvConfig.apiBaseUrl;
  static final int timeout = EnvConfig.apiTimeout;
  
  static Future<Response> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
    return await http.get(Uri.parse(url))
        .timeout(Duration(seconds: timeout));
  }
}
```

### Authentication Service
```dart
class AuthService {
  static Future<void> signInWithGoogle() async {
    if (!EnvConfig.enableSocialLogin) {
      throw Exception('Social login is disabled');
    }
    
    // Use EnvConfig.googleClientId for Google Sign-In
  }
}
```

### File Upload Service
```dart
class FileUploadService {
  static Future<void> uploadFile(File file) async {
    if (file.lengthSync() > EnvConfig.maxFileSize) {
      throw Exception('File too large');
    }
    
    // Upload to EnvConfig.storageBucket
  }
}
```

## 🚨 Troubleshooting

### Common Issues

1. **Environment variables not loading:**
   - Check if `.env` file exists in project root
   - Ensure `EnvConfig.initialize()` is called before using variables
   - Verify file format (no spaces around `=`)

2. **Values returning defaults:**
   - Check variable names match exactly (case-sensitive)
   - Ensure no extra spaces or quotes in `.env` file

3. **File not found errors:**
   - Ensure `.env` file is in the project root directory
   - Check file permissions

### Debug Commands

```dart
// Add this to debug environment loading
void debugEnvConfig() {
  print('Environment: ${EnvConfig.environment}');
  print('API Base URL: ${EnvConfig.apiBaseUrl}');
  print('Debug Mode: ${EnvConfig.debugMode}');
  print('All Variables: ${EnvConfig.getAll()}');
}
```

## 📚 Additional Resources

- [Flutter Environment Variables](https://flutter.dev/docs/deployment/environment-variables)
- [Dart File I/O](https://dart.dev/guides/libraries/library-tour#files-and-directories)
- [Environment Variables Best Practices](https://12factor.net/config)

---

**Remember:** Keep your `.env` file secure and never commit it to version control!
