import 'package:flutter/material.dart';

class CreateModel {
  static T create<T>(BuildContext context, T Function() modelBuilder) {
    return modelBuilder();
  }
}
