import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';
import '../data/dummy_hub_data.dart';
import '../services/api_service.dart';
import '../model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  
  // Check if current user is admin
  bool get isAdmin {
    final isAdminUser = _currentUser?.isAdminUser ?? false;
    print('🔍 AuthProvider.isAdmin: currentUser=${_currentUser?.id}, isAdminUser=$isAdminUser, result=$isAdminUser');
    return isAdminUser;
  }

  // Initialize and restore user session
  Future<void> initialize() async {
    print('🔍 AuthProvider: Initializing and checking for stored session...');
    
    // Debug: Check what's currently stored
    await debugCheckStoredSession();
    
    await _restoreUserSession();
  }

  // Save user session to local storage
  Future<void> _saveUserSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = user.toJson();
      final userDataString = jsonEncode(userData);
      await prefs.setString('user_data', userDataString);
      await prefs.setBool('is_logged_in', true);
      print('🔍 AuthProvider: User session saved to local storage');
      print('🔍 AuthProvider: Saved user data: $userDataString');
    } catch (e) {
      print('❌ AuthProvider: Error saving user session: $e');
    }
  }

  // Restore user session from local storage
  Future<void> _restoreUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      print('🔍 AuthProvider: Checking stored session - isLoggedIn: $isLoggedIn');
      
      if (isLoggedIn) {
        final userDataString = prefs.getString('user_data');
        print('🔍 AuthProvider: Retrieved user data string: $userDataString');
        
        if (userDataString != null && userDataString.isNotEmpty) {
          try {
            // Validate JSON format first
            if (!userDataString.startsWith('{') || !userDataString.endsWith('}')) {
              print('❌ AuthProvider: Invalid JSON format detected');
              await _clearUserSession();
              return;
            }
            
            final userData = Map<String, dynamic>.from(
              jsonDecode(userDataString) as Map<String, dynamic>
            );
            print('🔍 AuthProvider: Parsed user data: $userData');
            
            _currentUser = UserModel.fromJson(userData);
            print('🔍 AuthProvider: User session restored from local storage');
            print('🔍 AuthProvider: Restored user: id=${_currentUser?.id}, isAdmin=${_currentUser?.isAdmin}');
            notifyListeners();
          } catch (parseError) {
            print('❌ AuthProvider: Error parsing user data: $parseError');
            print('❌ AuthProvider: Raw string was: $userDataString');
            // Clear corrupted data
            await _clearUserSession();
          }
        } else {
          print('🔍 AuthProvider: No user data string found or empty string');
          if (userDataString != null && userDataString.isEmpty) {
            await _clearUserSession();
          }
        }
      } else {
        print('🔍 AuthProvider: No stored session found');
      }
    } catch (e) {
      print('❌ AuthProvider: Error restoring user session: $e');
    }
  }

  // Clear stored user session
  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.setBool('is_logged_in', false);
      print('🔍 AuthProvider: User session cleared from local storage');
    } catch (e) {
      print('❌ AuthProvider: Error clearing user session: $e');
    }
  }

  // Register user
  Future<bool> register({
    required String name,
    required String surname,
    required String email,
    required int phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.registerUser(
        name: name,
        surname: surname,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      _isLoading = false;

      if (result['success']) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  /// Dummy credentials for testing employer vs worker flow (when [EnvConfig.useMockData] is true).
  /// Employer: employer@businesshub.com / Test123!
  /// Worker:  worker@businesshub.com / Test123!
  static const String _dummyEmployerEmail = 'employer@businesshub.com';
  static const String _dummyWorkerEmail = 'worker@businesshub.com';
  static const String _dummyPassword = 'Test123!';

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔍 AuthProvider: Starting login for email: $email');

      // When using mock data, allow two dummy logins for testing employer vs worker
      if (EnvConfig.useMockData) {
        final emailTrimmed = email.trim().toLowerCase();
        final passwordOk = password == _dummyPassword;
        if (passwordOk && emailTrimmed == _dummyEmployerEmail) {
          _currentUser = _buildDummyUser('1', _dummyEmployerEmail);
          _isLoading = false;
          await _saveUserSession(_currentUser!);
          _errorMessage = null;
          notifyListeners();
          return true;
        }
        if (passwordOk && emailTrimmed == _dummyWorkerEmail) {
          _currentUser = _buildDummyUser('2', _dummyWorkerEmail);
          _isLoading = false;
          await _saveUserSession(_currentUser!);
          _errorMessage = null;
          notifyListeners();
          return true;
        }
      }

      final result = await ApiService.loginUser(
        email: email,
        password: password,
      );

      print('🔍 AuthProvider: Login result: $result');
      _isLoading = false;

      if (result['success']) {
        print('🔍 AuthProvider.login: API response data: ${result['data']}');
        _currentUser = UserModel.fromJson(result['data']);
        print('🔍 AuthProvider.login: Created user model: id=${_currentUser?.id}, isAdmin=${_currentUser?.isAdmin}');
        
        // Save user session to local storage
        await _saveUserSession(_currentUser!);
        
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ AuthProvider login error: ${e.toString()}');
      print('❌ AuthProvider error type: ${e.runtimeType}');
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  /// Dummy users are built without location so the app will prompt for location after login.
  UserModel _buildDummyUser(String id, String email) {
    final profile = DummyHubData.getDummyUser(id);
    return UserModel(
      id: id,
      name: profile?['name']?.toString(),
      surname: profile?['surname']?.toString(),
      email: email,
      city: profile?['city']?.toString(),
      latitude: null,
      longitude: null,
      isAdmin: false,
    );
  }

  /// Update current user's location (e.g. after permission granted). Persists to session.
  Future<void> updateUserLocation(double latitude, double longitude) async {
    if (_currentUser == null) return;
    final u = _currentUser!;
    _currentUser = UserModel(
      id: u.id,
      name: u.name,
      surname: u.surname,
      email: u.email,
      profilePhoto: u.profilePhoto,
      ratings: u.ratings,
      phoneNumber: u.phoneNumber,
      streetAddress: u.streetAddress,
      city: u.city,
      state: u.state,
      postalCode: u.postalCode,
      country: u.country,
      identificationDoc: u.identificationDoc,
      latitude: latitude,
      longitude: longitude,
      password: u.password,
      isAdmin: u.isAdmin,
    );
    await _saveUserSession(_currentUser!);
    notifyListeners();
  }

  // Logout user
  Future<void> logout() async {
    final isDummy = EnvConfig.useMockData &&
        (_currentUser?.email == _dummyEmployerEmail || _currentUser?.email == _dummyWorkerEmail);
    if (!isDummy) await ApiService.logout();
    _currentUser = null;
    _errorMessage = null;
    await _clearUserSession();
    notifyListeners();
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    print('🔍 AuthProvider: Checking authentication status...');
    
    // First try to restore from local storage
    await _restoreUserSession();
    
    // If we have a user from local storage, try to validate with API (skip for dummy test users)
    if (_currentUser != null) {
      final isDummyUser = EnvConfig.useMockData &&
          (_currentUser!.email == _dummyEmployerEmail || _currentUser!.email == _dummyWorkerEmail);
      if (isDummyUser) {
        print('🔍 AuthProvider: Dummy user restored from storage, skipping API validation');
        notifyListeners();
        return;
      }
      print('🔍 AuthProvider: User found in local storage, validating with API...');
      try {
        final isLoggedIn = await ApiService.isLoggedIn();
        if (isLoggedIn) {
          final result = await ApiService.getUserProfile();
          if (result['success']) {
            _currentUser = UserModel.fromJson(result['data']);
            // Update stored session with fresh data
            await _saveUserSession(_currentUser!);
            print('🔍 AuthProvider: User session validated with API');
          } else {
            // API validation failed, clear local session
            print('🔍 AuthProvider: API validation failed, clearing local session');
            await _clearUserSession();
            _currentUser = null;
          }
        } else {
          // API says not logged in, clear local session
          print('🔍 AuthProvider: API says not logged in, clearing local session');
          await _clearUserSession();
          _currentUser = null;
        }
      } catch (e) {
        print('❌ AuthProvider: Error checking auth status: $e');
        // On error, keep local session but mark as potentially stale
      }
    } else {
      print('🔍 AuthProvider: No local session found');
    }
    
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    String? profilePhoto,
    int? phoneNumber,
    String? identificationDoc,
    String? streetAddress,
    String? city,
    String? state,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔍 AuthProvider: Starting profile update');
      print('🔍 AuthProvider: Profile photo provided: ${profilePhoto != null}');
      if (profilePhoto != null) {
        print('🔍 AuthProvider: Profile photo length: ${profilePhoto.length}');
      }
      
      final result = await ApiService.updateProfile(
        userId: int.parse(_currentUser!.id!),
        profilePhoto: profilePhoto,
        phoneNumber: phoneNumber,
        identificationDoc: identificationDoc,
        streetAddress: streetAddress,
        city: city,
        state: state,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
      );

      print('🔍 AuthProvider: Update profile result: $result');
      _isLoading = false;

      if (result['success']) {
        _currentUser = UserModel.fromJson(result['data']);
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ AuthProvider update profile error: ${e.toString()}');
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh user data from API
  Future<void> refreshUserData() async {
    if (_currentUser == null) return;
    
    try {
      print('🔍 AuthProvider: Refreshing user data from API...');
      final result = await ApiService.getUserProfile();
      if (result['success']) {
        _currentUser = UserModel.fromJson(result['data']);
        await _saveUserSession(_currentUser!);
        print('🔍 AuthProvider: User data refreshed successfully');
        notifyListeners();
      }
    } catch (e) {
      print('❌ AuthProvider: Error refreshing user data: $e');
    }
  }

  // Force clear session (useful for debugging)
  Future<void> forceClearSession() async {
    print('🔍 AuthProvider: Force clearing session...');
    _currentUser = null;
    _errorMessage = null;
    await _clearUserSession();
    notifyListeners();
  }

  // Debug method to check stored session
  Future<void> debugCheckStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in');
      final userDataString = prefs.getString('user_data');
      
      print('🔍 AuthProvider Debug: isLoggedIn: $isLoggedIn');
      print('🔍 AuthProvider Debug: userDataString: $userDataString');
      
      if (userDataString != null) {
        print('🔍 AuthProvider Debug: String length: ${userDataString.length}');
        print('🔍 AuthProvider Debug: First char: ${userDataString.isNotEmpty ? userDataString[0] : 'empty'}');
        print('🔍 AuthProvider Debug: Last char: ${userDataString.isNotEmpty ? userDataString[userDataString.length - 1] : 'empty'}');
      }
    } catch (e) {
      print('❌ AuthProvider Debug: Error checking stored session: $e');
    }
  }
}
