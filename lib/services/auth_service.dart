import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../config/app_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Test connection to API
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: ${AppConfig.apiBaseUrl}');
      print('Testing endpoint: /user-management/count');
      
      final response = await ApiService.get('/user-management/count');
      print('Connection test successful: ${response.statusCode}');
      return true;
    } on ApiException catch (e) {
      print('Connection test failed with API error: ${e.message}');
      if (e.statusCode == 408) {
        print('Connection timed out - server may be slow or unreachable');
      } else if (e.statusCode == 0) {
        print('Network connectivity issue - check internet connection');
      } else if (e.statusCode == 404) {
        print('Endpoint not found - server may be running but endpoint is wrong');
      } else if (e.statusCode == 500) {
        print('Server error - backend is running but has internal errors');
      }
      return false;
    } catch (e) {
      print('Connection test failed with unexpected error: $e');
      return false;
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting to login with email: $email');
      print('API Base URL: ${AppConfig.apiBaseUrl}');
      print('Full Auth URL: ${AppConfig.authApiUrl}');
      
      // Test connection first
      final isConnected = await testConnection();
      if (!isConnected) {
        throw ApiException(
          statusCode: 0, 
          message: 'Cannot connect to server. Please check if the backend is running on port 3005.'
        );
      }
      
      // First, let's see what users exist in the database
      print('Getting all users to debug...');
      final allUsersResponse = await ApiService.get('/user-management');
      print('All users response status: ${allUsersResponse.statusCode}');
      print('All users response body: ${allUsersResponse.body}');
      
      // Now try to find user by email with different query approaches
      print('Searching for user with email: $email');
      
      // Try the standard Loopback4 filter syntax
      final userResponse = await ApiService.get('/user-management?filter[where][email]=$email');
      print('Standard filter response: ${userResponse.body}');
      
      // Try alternative query syntax
      final altUserResponse = await ApiService.get('/user-management?filter[where][email][like]=$email');
      print('Alternative filter response: ${altUserResponse.body}');
      
      // Try without filter
      final simpleResponse = await ApiService.get('/user-management?filter[where][email]=$email');
      print('Simple filter response: ${simpleResponse.body}');
      
      final userData = ApiService.handleResponse(userResponse);
      
      // Check if user exists
      if (userData is List && userData.isNotEmpty) {
        final user = userData[0];
        print('User found: ${user['email']}');
        print('Full user object: $user');
        print('User keys: ${user.keys.toList()}');
        
        // Check if password matches
        print('Stored password: ${user['password']}');
        print('Input password: $password');
        print('Password comparison: ${user['password'] == password}');
        
        if (user['password'] == password) {
          print('Password matches, logging in user');
          
          // Store token and user data
          await _storeToken(user['id'].toString());
          await _storeUserData(user);
          
          return user;
        } else {
          print('Password does not match');
          throw ApiException(statusCode: 401, message: 'Invalid email or password');
        }
      } else {
        print('No user found with email: $email');
        throw ApiException(statusCode: 401, message: 'User not found with this email');
      }
    } catch (e) {
      print('Login error: $e');
      throw _handleAuthError(e);
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      // Check if user already exists
      try {
        final existingUserResponse = await ApiService.get('/user-management?filter[where][email]=$email');
        final existingUsers = ApiService.handleResponse(existingUserResponse);
        
        if (existingUsers is List && existingUsers.isNotEmpty) {
          throw ApiException(statusCode: 400, message: 'User with this email already exists');
        }
      } catch (e) {
        if (e is ApiException && e.statusCode == 400) {
          rethrow; // Re-throw the "user already exists" error
        }
        // Continue with registration if no existing user found
      }
      
      // Register new user
      try {
        print('Registering new user with email: $email');
        final response = await ApiService.post('/user-management', {
          'name': name,
          'surname': surname,
          'email': email,
          'phone_number': phone ?? '',
          'password': password,
          'profile_photo': '',
          'ratings': 0,
          'street_address': '',
          'city': '',
          'state': '',
          'postal_code': '',
          'country': '',
          'identification_doc': '',
          'latitude': 0,
          'longitude': 0,
        });

        final data = ApiService.handleResponse(response);
        print('Registration successful: ${data['id']}');
        
        // Store user data
        await _storeUserData(data);
        return data;
      } catch (e) {
        print('Registration failed: $e');
        throw _handleAuthError(e);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Call logout endpoint if your API has one
        await ApiService.post('/user-management/logout', {}, token: token);
      }
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API call failed: $e');
    } finally {
      // Clear local storage
      await _clearToken();
      await _clearUserData();
    }
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await ApiService.get('/user-management', token: token);
      final data = ApiService.handleResponse(response);
      
      // Update stored user data
      await _storeUserData(data);
      
      return data;
    } catch (e) {
      // If getting current user fails, clear stored data
      await logout();
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Store token
  static Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Store user data
  static Future<void> _storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // Clear token
  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Clear user data
  static Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Handle authentication errors
  static String _handleAuthError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 401:
          return 'Invalid email or password';
        case 422:
          return 'Invalid data provided';
        case 409:
          return 'User already exists';
        case 500:
          return 'Server error. Please try again later';
        default:
          return error.message;
      }
    } else if (error.toString().contains('SocketException')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Refresh token (if your API supports it)
  static Future<String?> refreshToken() async {
    try {
      final currentToken = await getToken();
      if (currentToken == null) return null;

      final response = await ApiService.post('/api/users/refresh', {}, token: currentToken);
      final data = ApiService.handleResponse(response);
      
      await _storeToken(data['id']);
      return data['id'];
    } catch (e) {
      await logout();
      return null;
    }
  }
}
