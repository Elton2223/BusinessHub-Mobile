import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/filter_settings_model.dart';

const String _key = 'hub_filter_settings';

class FilterSettingsService {
  static Future<FilterSettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return FilterSettingsModel();
    try {
      return FilterSettingsModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(json) as Map),
      );
    } catch (_) {
      return FilterSettingsModel();
    }
  }

  static Future<void> save(FilterSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
