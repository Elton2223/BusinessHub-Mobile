import 'package:flutter/material.dart';

class SaiderbarModel {
  late bool isExpanded;
  late int selectedIndex;
  late bool isCollapsed;

  void initState(BuildContext context) {
    isExpanded = false;
    selectedIndex = 0;
    isCollapsed = false;
  }

  void dispose() {
    // Add dispose logic if needed
  }
}
