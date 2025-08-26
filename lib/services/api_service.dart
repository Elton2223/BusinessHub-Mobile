import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // Shared preferences keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String surname,
    required String email,
    required int phoneNumber,
    required String password,
  }) async {
    try {
      final requestBody = {
        'name': name,
        'surname': surname,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
      };
      
      print('Sending registration request: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.userManagementUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Registration successful',
        };
      } else {
        final errorData = jsonDecode(response.body);
        print('API Error Response: ${response.body}');
        return {
          'success': false,
          'message': errorData['error']?['message'] ?? errorData['details'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🔍 Attempting login for email: $email');
      print('🔍 Login URL: ${ApiConfig.userManagementUrl}/login');
      print('🔍 Request headers: ${ApiConfig.defaultHeaders}');
      
      final requestBody = {
        'email': email,
        'password': password,
      };
      print('🔍 Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.userManagementUrl}/login'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(requestBody),
      );
      
      print('🔍 Response status code: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Store authentication data
          await _storeAuthData(data['user']);
          
          return {
            'success': true,
            'data': data['user'],
            'message': data['message'] ?? 'Login successful',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error']?['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('❌ Login error: ${e.toString()}');
      print('❌ Error type: ${e.runtimeType}');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.userManagementUrl),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Profile retrieved successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to retrieve profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(userEmailKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _getStoredToken();
    return token != null;
  }

  // Get stored token
  static Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Store authentication data
  static Future<void> _storeAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (data['token'] != null) {
      await prefs.setString(tokenKey, data['token']);
    }
    
    if (data['user'] != null) {
      final user = data['user'];
      if (user['id'] != null) {
        await prefs.setString(userIdKey, user['id'].toString());
      }
      if (user['email'] != null) {
        await prefs.setString(userEmailKey, user['email']);
      }
    }
  }

  // Get stored user ID
  static Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  // Get stored user email
  static Future<String?> getStoredUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }
}
