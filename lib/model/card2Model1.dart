import 'package:flutter/material.dart';

class Card2Model1 {
  late bool isExpanded;
  late bool isSelected;

  void initState(BuildContext context) {
    isExpanded = false;
    isSelected = false;
  }

  void dispose() {
    // Add dispose logic if needed
  }
}
