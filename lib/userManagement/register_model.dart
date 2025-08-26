import 'package:flutter/material.dart';

class RegisterModel {
  // Text controllers and focus nodes for each field
  TextEditingController? textController1;
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController2;
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController3;
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController4;
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController5;
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController6;
  FocusNode? textFieldFocusNode6;
  TextEditingController? textController7;
  FocusNode? textFieldFocusNode7;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Password visibility
  bool passwordVisibility1 = false;
  bool passwordVisibility2 = false;

  // Validators
  String? textController1Validator(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? textController6Validator(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Surname is required';
    }
    return null;
  }

  String? textController2Validator(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Simple email validation
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? textController3Validator(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? textController4Validator(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? textController5Validator(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (textController4?.text != value) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? Function(BuildContext, String?) textController7Validator = (_, __) => null;

  void dispose() {
    textController1?.dispose();
    textFieldFocusNode1?.dispose();
    textController2?.dispose();
    textFieldFocusNode2?.dispose();
    textController3?.dispose();
    textFieldFocusNode3?.dispose();
    textController4?.dispose();
    textFieldFocusNode4?.dispose();
    textController5?.dispose();
    textFieldFocusNode5?.dispose();
    textController6?.dispose();
    textFieldFocusNode6?.dispose();
    textController7?.dispose();
    textFieldFocusNode7?.dispose();
  }
}
