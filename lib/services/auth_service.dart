import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../config/env_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Test connection to API
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: ${EnvConfig.apiBaseUrl}');
      final response = await ApiService.get('/user-management/count');
      print('Connection test successful: ${response.statusCode}');
      return true;
    } on ApiException catch (e) {
      print('Connection test failed with API error: ${e.message}');
      if (e.statusCode == 408) {
        print('Connection timed out - server may be slow or unreachable');
      } else if (e.statusCode == 0) {
        print('Network connectivity issue - check internet connection');
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
      print('API Base URL: ${EnvConfig.apiBaseUrl}');
      
      // Try the new authentication endpoint first
      try {
        final response = await ApiService.post('/auth/login', {
          'email': email,
          'password': password,
        });

        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        final data = ApiService.handleResponse(response);
        
        if (data['success'] == true) {
          // Store token and user data
          await _storeToken(data['user']['id'].toString());
          await _storeUserData(data['user']);
          return data['user'];
        } else {
          throw ApiException(statusCode: 401, message: data['message']);
        }
      } catch (e) {
        print('New auth endpoint failed, trying fallback method: $e');
        
        // Fallback to the old method using CRUD operations
        final response = await ApiService.get('/user-management?filter[where][email]=$email');

        print('Fallback response status code: ${response.statusCode}');
        print('Fallback response body: ${response.body}');

        final data = ApiService.handleResponse(response);
        
        // Check if user exists and password matches
        if (data is List && data.isNotEmpty) {
          final user = data[0];
          if (user['password'] == password) {
            // Store token and user data
            await _storeToken(user['id'].toString());
            await _storeUserData(user);

            return user;
          } else {
            throw ApiException(statusCode: 401, message: 'Invalid email or password');
          }
        } else {
          throw ApiException(statusCode: 401, message: 'Invalid email or password');
        }
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
      // Try the new authentication endpoint first
      try {
        final response = await ApiService.post('/auth/register', {
          'name': name,
          'surname': surname,
          'email': email,
          'phone_number': phone,
          'password': password,
        });

        final data = ApiService.handleResponse(response);
        
        if (data['success'] == true) {
          await _storeUserData(data['user']);
          return data['user'];
        } else {
          throw ApiException(statusCode: 400, message: data['message']);
        }
      } catch (e) {
        print('New auth endpoint failed, trying fallback method: $e');
        
        // Fallback to the old method using CRUD operations
        final response = await ApiService.post('/user-management', {
          'name': name,
          'surname': surname,
          'email': email,
          'profile_photo': 'NULL',
          'ratings': 0,
          'phone_number': phone,
          'street_address': 'NULL',
          'city': 'NULL',
          'state': 'NULL',
          'postal_code': 'NULL',
          'country': 'NULL',
          'identification_doc': 'NULL',
          'latitude': 0,
          'longitude': 0,
          'password': password,
        });

        final data = ApiService.handleResponse(response);
        
        // For registration, you might want to store the user data but not the token
        // since Loopback4 might require email verification
        await _storeUserData(data);

        return data;
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
        await ApiService.post('/api/users/logout', {}, token: token);
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

      final response = await ApiService.get('/api/users/me', token: token);
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
