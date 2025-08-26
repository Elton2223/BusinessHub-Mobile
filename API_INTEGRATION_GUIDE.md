# BusinessHub Mobile - API Integration Guide

## Overview
This guide explains the API integration implemented for the BusinessHub Mobile app, connecting to a LoopBack4 backend for user registration and login functionality.

## Database Structure
The user management table has the following structure:
```sql
- id (Primary Key, Auto Increment)
- name (varchar(255))
- surname (varchar(255))
- email (varchar(255))
- profile_photo (varchar(500), nullable)
- ratings (int(11), nullable)
- phone_number (int(13), nullable)
- street_address (varchar(500), nullable)
- city (varchar(500), nullable)
- state (varchar(500), nullable)
- postal_code (varchar(500), nullable)
- country (varchar(500), nullable)
- identification_doc (double, nullable)
- latitude (double, nullable)
- longitude (double, nullable)
- password (varchar(500))
```

## API Configuration

### Base Configuration (`lib/config/api_config.dart`)
```dart
class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:3005';
  static const String userManagementEndpoint = '/user-management';
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static String get userManagementUrl => '$baseUrl$userManagementEndpoint';
}
```

### Environment Configuration (`lib/config/env_config.dart`)
Handles environment variables and provides fallback values for development.

## API Service (`lib/services/api_service.dart`)

### Registration
```dart
static Future<Map<String, dynamic>> registerUser({
  required String name,
  required String surname,
  required String email,
  required String phoneNumber,
  required String password,
}) async
```

**Request Body:**
```json
{
  "name": "John",
  "surname": "Doe",
  "email": "john.doe@example.com",
  "phone_number": "1234567890",
  "password": "securepassword"
}
```

### Login
```dart
static Future<Map<String, dynamic>> loginUser({
  required String email,
  required String password,
}) async
```

**Request Body:**
```json
{
  "email": "john.doe@example.com",
  "password": "securepassword"
}
```

## State Management (`lib/providers/auth_provider.dart`)

The app uses the `provider` package for state management with an `AuthProvider` that:

- Manages authentication state
- Handles loading states
- Displays error messages
- Stores user data locally using `shared_preferences`

### Key Methods:
- `register()` - Register new user
- `login()` - Authenticate user
- `logout()` - Clear authentication data
- `checkAuthStatus()` - Check if user is logged in

## User Model (`lib/models/user_model.dart`)

```dart
class UserModel {
  final String? id;
  final String? name;
  final String? surname;
  final String? email;
  final String? profilePhoto;
  final int? ratings;
  final String? phoneNumber;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final double? identificationDoc;
  final double? latitude;
  final double? longitude;
  final String? password;
  
  // Getter for full name
  String get fullName => '$name $surname'.trim();
}
```

## UI Integration

### Registration Page (`lib/userManagement/register.dart`)
- Separate fields for name and surname
- Form validation
- API integration with loading states
- Error message display
- Success navigation to login

### Login Page (`lib/userManagement/login.dart`)
- Email and password fields
- API integration with loading states
- Error message display
- Success navigation to home

## Dependencies

Add these to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.5
```

## Setup Instructions

1. **Start LoopBack4 Backend**
   ```bash
   # Navigate to your LoopBack4 project
   cd business-hub-backend
   npm start
   ```
   The backend should be running on `http://127.0.0.1:3005`

2. **Update API Configuration**
   - Modify `lib/config/api_config.dart` if your backend runs on a different port
   - Update the `userManagementEndpoint` if your API path is different

3. **Test the Integration**
   - Run the Flutter app: `flutter run`
   - Try registering a new user
   - Try logging in with the registered credentials

## Error Handling

The app handles various error scenarios:
- Network connectivity issues
- Invalid credentials
- Server errors
- Validation errors

Error messages are displayed in red containers below the form fields.

## Security Considerations

- Passwords are sent in plain text (consider implementing HTTPS in production)
- Authentication tokens are stored locally using `shared_preferences`
- No password hashing on the client side (handled by backend)

## Testing

### Manual Testing
1. **Registration Flow:**
   - Fill all required fields
   - Submit registration
   - Verify success message
   - Navigate to login

2. **Login Flow:**
   - Enter registered email and password
   - Submit login
   - Verify navigation to home page

3. **Error Scenarios:**
   - Try registering with existing email
   - Try logging in with wrong credentials
   - Test network connectivity issues

### API Testing
You can test the API endpoints directly using tools like Postman or curl:

**Register User:**
```bash
curl -X POST http://127.0.0.1:3005/user-management \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test",
    "surname": "User",
    "email": "test@example.com",
    "phone_number": 1234567890,
    "password": "password123"
  }'
```

**Login User:**
```bash
curl -X POST http://127.0.0.1:3005/user-management \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

## Troubleshooting

### Common Issues:

1. **Network Error: Connection refused**
   - Ensure LoopBack4 backend is running
   - Check if the port (3005) is correct
   - Verify firewall settings

2. **API Endpoint not found**
   - Check the `userManagementEndpoint` in `ApiConfig`
   - Verify the endpoint exists in your LoopBack4 API

3. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Check for dependency conflicts

4. **Authentication Issues**
   - Verify the request format matches your backend expectations
   - Check if the backend requires additional headers

## Future Enhancements

- Implement HTTPS for production
- Add password strength validation
- Implement social login (Google, Facebook)
- Add biometric authentication
- Implement refresh tokens
- Add offline support with local caching
