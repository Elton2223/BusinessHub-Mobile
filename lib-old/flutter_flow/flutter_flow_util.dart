import 'package:flutter/material.dart';

T createModel<T>(BuildContext context, T Function() modelBuilder) => modelBuilder();
