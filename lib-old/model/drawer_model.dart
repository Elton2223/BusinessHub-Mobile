import 'package:businesshub_mobile/home_model.dart';

class DrawerModel {
  void dispose() {}
}

// Add this field or getter to your HomeModel class
extension DrawerModelExtension on HomeModel {
  DrawerModel get drawerModel => DrawerModel();
}