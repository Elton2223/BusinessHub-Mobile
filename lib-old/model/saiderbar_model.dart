import 'package:businesshub_mobile/home_model.dart';

class SaiderBarModel {
  void dispose() {}
}

// Add this field or getter to your HomeModel class
extension SaiderModelExtension on HomeModel {
  SaiderBarModel get drawerModel => SaiderBarModel();
}

