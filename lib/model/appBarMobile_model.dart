import 'package:flutter/material.dart';

class AppBarMobileModel {
  late bool isMenuOpen;
  late bool isSearchVisible;
  late TextEditingController searchController;
  late FocusNode searchFocusNode;

  void initState(BuildContext context) {
    isMenuOpen = false;
    isSearchVisible = false;
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
  }

  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
  }
}
