import 'package:flutter/material.dart';

class AppBarModel {
  late bool isExpanded;
  late bool isSearchVisible;
  late TextEditingController searchController;
  late FocusNode searchFocusNode;

  void initState(BuildContext context) {
    isExpanded = false;
    isSearchVisible = false;
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
  }

  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
  }
}
