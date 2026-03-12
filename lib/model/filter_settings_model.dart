/// User preferences for filtering hubs (location range, areas, categories, ongoing only).
/// Stored locally (SharedPreferences); backend can optionally sync /user/preferences.
class FilterSettingsModel {
  final double locationRangeKm;
  final List<String> areaNames;
  final List<String> categories;
  final bool ongoingOnly;
  final bool availableOnly;

  FilterSettingsModel({
    this.locationRangeKm = 50.0,
    this.areaNames = const [],
    this.categories = const [],
    this.ongoingOnly = false,
    this.availableOnly = false,
  });

  FilterSettingsModel copyWith({
    double? locationRangeKm,
    List<String>? areaNames,
    List<String>? categories,
    bool? ongoingOnly,
    bool? availableOnly,
  }) {
    return FilterSettingsModel(
      locationRangeKm: locationRangeKm ?? this.locationRangeKm,
      areaNames: areaNames ?? this.areaNames,
      categories: categories ?? this.categories,
      ongoingOnly: ongoingOnly ?? this.ongoingOnly,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationRangeKm': locationRangeKm,
      'areaNames': areaNames,
      'categories': categories,
      'ongoingOnly': ongoingOnly,
      'availableOnly': availableOnly,
    };
  }

  factory FilterSettingsModel.fromJson(Map<String, dynamic> json) {
    return FilterSettingsModel(
      locationRangeKm: (json['locationRangeKm'] ?? 50.0).toDouble(),
      areaNames: json['areaNames'] != null
          ? List<String>.from(json['areaNames'])
          : [],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      ongoingOnly: json['ongoingOnly'] == true,
      availableOnly: json['availableOnly'] == true,
    );
  }
}
