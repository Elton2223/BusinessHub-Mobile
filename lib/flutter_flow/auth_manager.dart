import 'package:flutter/material.dart';

class AuthManager {
  static bool isAuthenticated = false;
  static String? currentUserEmail;
  
  static void signIn(String email) {
    isAuthenticated = true;
    currentUserEmail = email;
  }
  
  static void signOut() {
    isAuthenticated = false;
    currentUserEmail = null;
  }
  
  static bool get isLoggedIn => isAuthenticated;
}
