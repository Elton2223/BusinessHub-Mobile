import 'package:flutter/material.dart';

class HomeModel {
  ///  State fields for stateful widgets in this page.

  late dynamic drawerModel;
  late dynamic saiderBarModel;
  late dynamic appBarMobileModel;
  late dynamic appBarModel;

  void initState(BuildContext context) {
    drawerModel = Object();
    saiderBarModel = Object();
    appBarMobileModel = Object();
    appBarModel = Object();
  }

  void dispose() {
    // Add dispose logic if your models have dispose methods
  }
}
