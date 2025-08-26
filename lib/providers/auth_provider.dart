import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      final result = await ApiService.loginUser(
        email: email,
        password: password,
      );

      print('🔍 AuthProvider: Login result: $result');
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
      print('❌ AuthProvider login error: ${e.toString()}');
      print('❌ AuthProvider error type: ${e.runtimeType}');
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    await ApiService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await ApiService.isLoggedIn();
    if (isLoggedIn) {
      final result = await ApiService.getUserProfile();
      if (result['success']) {
        _currentUser = UserModel.fromJson(result['data']);
        notifyListeners();
      }
    }
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
}
