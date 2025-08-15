import 'package:businesshub_mobile/home_model.dart';

class AppBarMobileModel {
  void dispose() {}
}

// Add this field or getter to your HomeModel class
extension AppBarMobileModelExtension on HomeModel {
  AppBarMobileModel get drawerModel => AppBarMobileModel();
}

