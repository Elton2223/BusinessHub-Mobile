import 'package:flutter/material.dart';

class DrawerModel {
  late bool isExpanded;
  late int selectedIndex;

  void initState(BuildContext context) {
    isExpanded = false;
    selectedIndex = 0;
  }

  void dispose() {
    // Add dispose logic if needed
  }
}
