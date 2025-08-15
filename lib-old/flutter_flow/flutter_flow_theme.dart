import 'package:flutter/material.dart';

class FlutterFlowTheme {
  static FlutterFlowThemeData of(BuildContext context) => FlutterFlowThemeData();
}

class FlutterFlowThemeData {
  Color get primaryBackground => Colors.white;
  Color get primaryText => Colors.black;
  Color get secondaryText => Colors.grey;
  Color get lineColor => Colors.grey.shade300;
  Color get primaryColor => Colors.black;
  Color get errorColor => Colors.red;
  Color get info => Colors.blue;
  TextStyle get title1 => const TextStyle(fontSize: 22, fontWeight: FontWeight.w500);
  TextStyle get bodyText1 => const TextStyle(fontSize: 14);
}
