import 'package:businesshub_mobile/home_model.dart';

class AppBarModel {
  void dispose() {}
}

// Add this field or getter to your HomeModel class
extension AppBarModelExtension on HomeModel {
  AppBarModel get drawerModel => AppBarModel();
}

