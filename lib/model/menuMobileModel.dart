import 'package:flutter/material.dart';

class MenuMobileModel {
  late bool isOpen;
  late int selectedIndex;

  void initState(BuildContext context) {
    isOpen = false;
    selectedIndex = 0;
  }

  void dispose() {
    // Add dispose logic if needed
  }
}
