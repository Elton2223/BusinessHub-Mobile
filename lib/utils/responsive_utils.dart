import 'package:flutter/material.dart';

class ResponsiveUtils {
  static ResponsiveUtils? _instance;
  static ResponsiveUtils get instance => _instance ??= ResponsiveUtils._internal();
  
  ResponsiveUtils._internal();

  // Screen dimensions
  late double screenWidth;
  late double screenHeight;
  late double aspectRatio;
  late Orientation orientation;
  late double pixelRatio;
  late EdgeInsets viewPadding;
  late EdgeInsets padding;

  // Responsive breakpoints
  static const double extraSmallBreakpoint = 360.0; // Small phones
  static const double smallBreakpoint = 600.0; // Large phones, small tablets
  static const double mediumBreakpoint = 900.0; // Tablets
  static const double largeBreakpoint = 1200.0; // Large tablets, small desktops
  static const double extraLargeBreakpoint = 1400.0; // Large desktops

  // Device type checks
  bool get isExtraSmallScreen => screenWidth < extraSmallBreakpoint;
  bool get isSmallScreen => screenWidth >= extraSmallBreakpoint && screenWidth < smallBreakpoint;
  bool get isMediumScreen => screenWidth >= smallBreakpoint && screenWidth < mediumBreakpoint;
  bool get isLargeScreen => screenWidth >= mediumBreakpoint && screenWidth < largeBreakpoint;
  bool get isExtraLargeScreen => screenWidth >= largeBreakpoint;

  // Orientation checks
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // Device type checks
  bool get isTablet => screenWidth >= smallBreakpoint && screenWidth < largeBreakpoint;
  bool get isPhone => screenWidth < smallBreakpoint;
  bool get isDesktop => screenWidth >= largeBreakpoint;

  // Dynamic sizing based on screen characteristics
  double get baseFontSize {
    if (isExtraSmallScreen) return 12.0;
    if (isSmallScreen) return 14.0;
    if (isMediumScreen) return 16.0;
    if (isLargeScreen) return 18.0;
    return 20.0;
  }

  double get basePadding {
    if (isExtraSmallScreen) return 8.0;
    if (isSmallScreen) return 12.0;
    if (isMediumScreen) return 16.0;
    if (isLargeScreen) return 20.0;
    return 24.0;
  }

  // AppBar responsive values
  double get appBarHeight {
    if (isExtraSmallScreen) return 48.0;
    if (isSmallScreen) return 56.0;
    if (isMediumScreen) return 64.0;
    if (isLargeScreen) return 72.0;
    return 80.0;
  }

  double get appBarButtonSize {
    if (isExtraSmallScreen) return 32.0;
    if (isSmallScreen) return 36.0;
    if (isMediumScreen) return 40.0;
    if (isLargeScreen) return 44.0;
    return 48.0;
  }

  double get appBarIconSize {
    if (isExtraSmallScreen) return 16.0;
    if (isSmallScreen) return 18.0;
    if (isMediumScreen) return 20.0;
    if (isLargeScreen) return 22.0;
    return 24.0;
  }

  // Container responsive values
  double get containerHeight {
    if (isExtraSmallScreen) return 160.0;
    if (isSmallScreen) return 180.0;
    if (isMediumScreen) return 200.0;
    if (isLargeScreen) return 220.0;
    return 240.0;
  }

  double get containerPadding {
    if (isExtraSmallScreen) return 8.0;
    if (isSmallScreen) return 12.0;
    if (isMediumScreen) return 16.0;
    if (isLargeScreen) return 20.0;
    return 24.0;
  }

  // Text responsive values
  double get headlineFontSize {
    if (isExtraSmallScreen) return 14.0;
    if (isSmallScreen) return 16.0;
    if (isMediumScreen) return 18.0;
    if (isLargeScreen) return 20.0;
    return 22.0;
  }

  double get bodyFontSize {
    if (isExtraSmallScreen) return 10.0;
    if (isSmallScreen) return 12.0;
    if (isMediumScreen) return 13.0;
    if (isLargeScreen) return 14.0;
    return 15.0;
  }

  double get titleFontSize {
    if (isExtraSmallScreen) return 16.0;
    if (isSmallScreen) return 18.0;
    if (isMediumScreen) return 20.0;
    if (isLargeScreen) return 22.0;
    return 24.0;
  }

  double get smallFontSize {
    if (isExtraSmallScreen) return 8.0;
    if (isSmallScreen) return 10.0;
    if (isMediumScreen) return 11.0;
    if (isLargeScreen) return 12.0;
    return 13.0;
  }

  // Spacing responsive values
  double get smallSpacing {
    if (isExtraSmallScreen) return 4.0;
    if (isSmallScreen) return 6.0;
    if (isMediumScreen) return 8.0;
    if (isLargeScreen) return 10.0;
    return 12.0;
  }

  double get mediumSpacing {
    if (isExtraSmallScreen) return 6.0;
    if (isSmallScreen) return 8.0;
    if (isMediumScreen) return 12.0;
    if (isLargeScreen) return 16.0;
    return 20.0;
  }

  double get largeSpacing {
    if (isExtraSmallScreen) return 8.0;
    if (isSmallScreen) return 12.0;
    if (isMediumScreen) return 16.0;
    if (isLargeScreen) return 20.0;
    return 24.0;
  }

  double get extraLargeSpacing {
    if (isExtraSmallScreen) return 12.0;
    if (isSmallScreen) return 16.0;
    if (isMediumScreen) return 20.0;
    if (isLargeScreen) return 24.0;
    return 28.0;
  }

  // Button responsive values
  double get buttonHeight {
    if (isExtraSmallScreen) return 36.0;
    if (isSmallScreen) return 40.0;
    if (isMediumScreen) return 44.0;
    if (isLargeScreen) return 48.0;
    return 52.0;
  }

  double get smallButtonHeight {
    if (isExtraSmallScreen) return 28.0;
    if (isSmallScreen) return 32.0;
    if (isMediumScreen) return 36.0;
    if (isLargeScreen) return 40.0;
    return 44.0;
  }

  // Border radius responsive values
  double get smallBorderRadius {
    if (isExtraSmallScreen) return 8.0;
    if (isSmallScreen) return 10.0;
    if (isMediumScreen) return 12.0;
    if (isLargeScreen) return 14.0;
    return 16.0;
  }

  double get mediumBorderRadius {
    if (isExtraSmallScreen) return 12.0;
    if (isSmallScreen) return 14.0;
    if (isMediumScreen) return 16.0;
    if (isLargeScreen) return 18.0;
    return 20.0;
  }

  double get largeBorderRadius {
    if (isExtraSmallScreen) return 16.0;
    if (isSmallScreen) return 18.0;
    if (isMediumScreen) return 20.0;
    if (isLargeScreen) return 22.0;
    return 24.0;
  }

  // Card responsive values
  double get cardPadding {
    if (isExtraSmallScreen) return 8.0;
    if (isSmallScreen) return 12.0;
    if (isMediumScreen) return 16.0;
    if (isLargeScreen) return 20.0;
    return 24.0;
  }

  double get cardMargin {
    if (isExtraSmallScreen) return 4.0;
    if (isSmallScreen) return 6.0;
    if (isMediumScreen) return 8.0;
    if (isLargeScreen) return 12.0;
    return 16.0;
  }

  // Form field responsive values
  double get formFieldHeight {
    if (isExtraSmallScreen) return 40.0;
    if (isSmallScreen) return 44.0;
    if (isMediumScreen) return 48.0;
    if (isLargeScreen) return 52.0;
    return 56.0;
  }

  double get formFieldPadding {
    if (isExtraSmallScreen) return 8.0;
    if (isSmallScreen) return 10.0;
    if (isMediumScreen) return 12.0;
    if (isLargeScreen) return 14.0;
    return 16.0;
  }

  // Initialize with MediaQuery data
  void initialize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    aspectRatio = screenWidth / screenHeight;
    orientation = mediaQuery.orientation;
    pixelRatio = mediaQuery.devicePixelRatio;
    viewPadding = mediaQuery.viewPadding;
    padding = mediaQuery.padding;
  }

  // Get responsive padding
  EdgeInsets getResponsivePadding({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.fromLTRB(
      left ?? basePadding,
      top ?? basePadding,
      right ?? basePadding,
      bottom ?? basePadding,
    );
  }

  // Get responsive margin
  EdgeInsets getResponsiveMargin({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.fromLTRB(
      left ?? basePadding,
      top ?? basePadding,
      right ?? basePadding,
      bottom ?? basePadding,
    );
  }

  // Get responsive spacing
  double getResponsiveSpacing(double baseValue) {
    if (isExtraSmallScreen) return baseValue * 0.7;
    if (isSmallScreen) return baseValue * 0.85;
    if (isMediumScreen) return baseValue;
    if (isLargeScreen) return baseValue * 1.15;
    return baseValue * 1.3;
  }

  // Get optimal text scale factor
  double get textScaleFactor {
    if (isExtraSmallScreen) return 0.8;
    if (isSmallScreen) return 0.9;
    if (isMediumScreen) return 1.0;
    if (isLargeScreen) return 1.1;
    return 1.2;
  }

  // Get optimal icon scale factor
  double get iconScaleFactor {
    if (isExtraSmallScreen) return 0.8;
    if (isSmallScreen) return 0.9;
    if (isMediumScreen) return 1.0;
    if (isLargeScreen) return 1.1;
    return 1.2;
  }

  // Get responsive grid cross axis count
  int getResponsiveGridCount({
    int? extraSmall,
    int? small,
    int? medium,
    int? large,
    int? extraLarge,
  }) {
    if (isExtraSmallScreen) return extraSmall ?? 1;
    if (isSmallScreen) return small ?? 1;
    if (isMediumScreen) return medium ?? 2;
    if (isLargeScreen) return large ?? 3;
    return extraLarge ?? 4;
  }

  // Get responsive aspect ratio
  double getResponsiveAspectRatio({
    double? extraSmall,
    double? small,
    double? medium,
    double? large,
    double? extraLarge,
  }) {
    if (isExtraSmallScreen) return extraSmall ?? 1.0;
    if (isSmallScreen) return small ?? 1.0;
    if (isMediumScreen) return medium ?? 1.2;
    if (isLargeScreen) return large ?? 1.5;
    return extraLarge ?? 2.0;
  }
}

// Extension for easy access
extension ResponsiveUtilsExtension on BuildContext {
  ResponsiveUtils get responsive {
    final responsiveUtils = ResponsiveUtils.instance;
    responsiveUtils.initialize(this);
    return responsiveUtils;
  }
}

// Responsive widget mixin
mixin ResponsiveWidgetMixin<T extends StatefulWidget> on State<T> {
  ResponsiveUtils get responsive => context.responsive;
  
  // Helper methods for responsive layouts
  Widget responsiveColumn({
    required List<Widget> children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  Widget responsiveRow({
    required List<Widget> children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  Widget responsiveContainer({
    Widget? child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    double? width,
    double? height,
    AlignmentGeometry? alignment,
  }) {
    return Container(
      padding: padding ?? responsive.getResponsivePadding(),
      margin: margin ?? responsive.getResponsiveMargin(),
      decoration: decoration,
      width: width,
      height: height,
      alignment: alignment,
      child: child,
    );
  }

  Widget responsiveCard({
    Widget? child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    double? elevation,
  }) {
    return Card(
      elevation: elevation ?? 2.0,
      margin: margin ?? responsive.getResponsiveMargin(),
      child: Container(
        padding: padding ?? responsive.getResponsivePadding(),
        child: child,
      ),
    );
  }

  Widget responsiveButton({
    required VoidCallback? onPressed,
    required Widget child,
    double? height,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    return SizedBox(
      height: height ?? responsive.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding ?? responsive.getResponsivePadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? responsive.mediumBorderRadius,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget responsiveTextField({
    required String labelText,
    TextEditingController? controller,
    String? hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      height: height ?? responsive.formFieldHeight,
      padding: padding ?? responsive.getResponsivePadding(),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              responsive.smallBorderRadius,
            ),
          ),
          contentPadding: responsive.getResponsivePadding(),
        ),
      ),
    );
  }

  // Enhanced responsive features
  Widget responsiveIcon({
    required IconData icon,
    Color? color,
    double? size,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(8),
      child: Icon(
        icon,
        color: color,
        size: size ?? responsive.iconScaleFactor * 24,
      ),
    );
  }

  Widget responsiveSpacer({double? height}) {
    return SizedBox(height: height ?? responsive.mediumSpacing);
  }

  Widget responsiveDivider({
    double? thickness,
    Color? color,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        thickness: thickness ?? (responsive.isTablet ? 2 : 1),
        color: color ?? Colors.grey[300],
      ),
    );
  }

  Widget responsiveChip({
    required String label,
    VoidCallback? onDeleted,
    Color? backgroundColor,
    Color? labelColor,
    double? fontSize,
  }) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize ?? responsive.smallFontSize,
          color: labelColor,
        ),
      ),
      backgroundColor: backgroundColor,
      onDeleted: onDeleted,
      deleteIcon: onDeleted != null 
          ? Icon(
              Icons.close,
              size: responsive.iconScaleFactor * 16,
            )
          : null,
    );
  }

  Widget responsiveListTile({
    required Widget leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding ?? EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    );
  }

  Widget responsiveGrid({
    required List<Widget> children,
    int? crossAxisCount,
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount ?? responsive.getResponsiveGridCount(),
      childAspectRatio: childAspectRatio ?? responsive.getResponsiveAspectRatio(),
      crossAxisSpacing: crossAxisSpacing ?? responsive.mediumSpacing,
      mainAxisSpacing: mainAxisSpacing ?? responsive.mediumSpacing,
      children: children,
    );
  }
}
